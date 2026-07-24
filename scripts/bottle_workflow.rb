# typed: strict
# frozen_string_literal: true

require "json"
require "open3"
require "optparse"
require "shellwords"
require "tsort"
require "English"

# Implements the build and publication decisions shared by the bottle workflows.
module BottleWorkflow
  class Error < StandardError; end

  # Runs external commands while preserving their output in GitHub Actions logs.
  class CommandRunner
    def capture!(*command)
      log(command)
      stdout, stderr, status = Open3.capture3(*command)
      return stdout if status.success?

      raise Error, command_failure(command, status.exitstatus, stdout, stderr)
    end

    def run!(*command)
      log(command)
      return if system(*command)

      raise Error, "Command failed with status #{$CHILD_STATUS&.exitstatus || "unknown"}: #{Shellwords.join(command)}"
    end

    def success?(*command, quiet: false)
      log(command)
      if quiet
        system(*command, out: File::NULL, err: File::NULL)
      else
        system(*command)
      end
    end

    private

    def log(command)
      puts "+ #{Shellwords.join(command)}"
    end

    def command_failure(command, status, stdout, stderr)
      details = [stdout, stderr].reject(&:empty?).join
      message = "Command failed with status #{status}: #{Shellwords.join(command)}"
      details.empty? ? message : "#{message}\n#{details}"
    end
  end

  # Provides the Homebrew formula operations that require Homebrew's Ruby runtime.
  class HomebrewFormulaService
    def initialize
      require "formula_installer"
    end

    def order(names)
      graph = names.to_h do |name|
        formula = Formula[name]
        [formula.full_name, formula]
      end
      graph.extend(TSort)
      graph.define_singleton_method(:tsort_each_node) do |&block|
        each_key(&block)
      end
      graph.define_singleton_method(:tsort_each_child) do |name, &block|
        fetch(name).deps.each do |dependency|
          dependency_name = dependency.to_formula.full_name
          block.call(dependency_name) if key?(dependency_name)
        end
      end

      graph.tsort
    end

    def unsatisfied_requirement_messages(name)
      formula = Formula[name]
      installer = FormulaInstaller.new(formula, build_bottle: true)
      unsatisfied, = installer.expand_requirements
      unsatisfied.values.flatten.map(&:message)
    end

    def identity(name)
      formula = Formula[name]
      [formula.name, formula.pkg_version.to_s]
    end
  end

  # Retrieves structured data through the authenticated GitHub CLI.
  class GitHubClient
    def initialize(runner, token)
      @runner = runner
      @token = token
    end

    def get(endpoint)
      JSON.parse(with_token { @runner.capture!("gh", "api", endpoint) })
    rescue JSON::ParserError => e
      raise Error, "GitHub API returned invalid JSON for #{endpoint}: #{e.message}"
    end

    private

    def with_token
      previous_token = ENV.fetch("GH_TOKEN", nil)
      ENV["GH_TOKEN"] = @token
      yield
    ensure
      if previous_token
        ENV["GH_TOKEN"] = previous_token
      else
        ENV.delete("GH_TOKEN")
      end
    end
  end

  module_function

  def required_value(value, name)
    raise Error, "Missing required value: #{name}" if value.blank?

    value
  end

  def parse_formulae(value)
    value.to_s.split(",").map(&:strip).reject(&:empty?).uniq
  end

  def write_output(output_path, name, value)
    required_value(output_path, "--output")
    File.open(output_path, "a") { |output| output.puts "#{name}=#{value}" }
  end

  def select_formulae(event_name:, requested_formulae:, base_ref:, output_path:, runner:, root: Pathname.pwd)
    formulae = if required_value(event_name, "--event") == "workflow_dispatch"
      requested = parse_formulae(requested_formulae)
      if requested.empty?
        Dir.glob(root.join("Formula", "*.rb")).map do |path|
          "block/tap/#{File.basename(path, ".rb")}"
        end
      else
        requested
      end
    else
      required_value(base_ref, "--base-ref")
      changed_paths = runner.capture!(
        "git", "diff", "--diff-filter=AMR", "--name-only", "origin/#{base_ref}...HEAD", "--", "Formula/*.rb"
      )
      changed_paths.lines.filter_map do |line|
        match = line.strip.match(%r{\AFormula/(.+)\.rb\z})
        "block/tap/#{match[1]}" if match
      end.uniq
    end

    value = formulae.join(",")
    write_output(output_path, "value", value)
    puts formulae.empty? ? "No formulae selected." : "Selected formulae: #{value}"
    formulae
  end

  def build_bottles(formulae:, repository:, runner:, formula_service:)
    formulae = parse_formulae(required_value(formulae, "--formulae"))
    required_value(repository, "--repository")

    formula_service.order(formulae).each do |formula|
      requirement_messages = formula_service.unsatisfied_requirement_messages(formula)
      unless requirement_messages.empty?
        puts "Skipping #{formula} on this runner:"
        requirement_messages.each { |message| puts message }
        next
      end

      # A target may already be installed as another target's dependency. Rebuild it cleanly.
      if runner.success?("brew", "list", "--formula", "--versions", formula, quiet: true)
        runner.run!("brew", "uninstall", "--formula", "--force", formula)
      end
      runner.run!("brew", "install", "--build-bottle", "--no-ask", formula)
      runner.run!("brew", "test", formula)

      name, pkg_version = formula_service.identity(formula)
      root_url = "https://github.com/#{repository}/releases/download/#{name}-#{pkg_version}"
      runner.run!("brew", "bottle", "--json", "--root-url=#{root_url}", formula)
    end
  end

  def find_publish_run(repository:, sha:, output_path:, token:, runner:, github: GitHubClient.new(runner, token))
    required_value(repository, "--repository")
    required_value(sha, "--sha")
    required_value(token, "HOMEBREW_GITHUB_API_TOKEN")

    pull_requests = github.get("repos/#{repository}/commits/#{sha}/pulls")
    pull_request = pull_requests.find { |candidate| candidate["merged_at"] }
    unless pull_request
      puts "No merged pull request is associated with #{sha}."
      return
    end

    number = pull_request.fetch("number")
    head_sha = pull_request.fetch("head").fetch("sha")
    files = github.get("repos/#{repository}/pulls/#{number}/files?per_page=100")
    formula_changed = files.any? do |file|
      filename = file.fetch("filename")
      file.fetch("status") != "removed" && filename.start_with?("Formula/") && filename.end_with?(".rb")
    end
    unless formula_changed
      puts "Pull request ##{number} did not produce bottles."
      return
    end

    runs = github.get(
      "repos/#{repository}/actions/workflows/build-bottles.yml/runs" \
      "?head_sha=#{head_sha}&event=pull_request&status=success&per_page=1",
    )
    run_id = runs.fetch("workflow_runs").first&.fetch("id")
    raise Error, "No successful bottle build found for pull request ##{number} at #{head_sha}." unless run_id

    artifact_response = github.get("repos/#{repository}/actions/runs/#{run_id}/artifacts?per_page=100")
    artifact_found = artifact_response.fetch("artifacts").any? do |artifact|
      artifact["expired"] == false && artifact.fetch("name").start_with?("bottles_")
    end
    raise Error, "Bottle build #{run_id} has no bottle artifacts." unless artifact_found

    write_output(output_path, "run_id", run_id)
    puts "Using bottle artifacts from run #{run_id} for pull request ##{number} at #{head_sha}."
    run_id
  end

  def select_options(argv)
    options = { event_name: nil, requested_formulae: "", base_ref: "", output_path: nil }
    OptionParser.new do |parser|
      parser.on("--event EVENT") { |value| options[:event_name] = value }
      parser.on("--base-ref REF") { |value| options[:base_ref] = value }
      parser.on("--requested FORMULAE") { |value| options[:requested_formulae] = value }
      parser.on("--output PATH") { |value| options[:output_path] = value }
    end.parse!(argv)
    raise Error, "Unexpected arguments: #{argv.join(" ")}" unless argv.empty?

    options
  end

  def build_options(argv)
    options = { formulae: nil, repository: nil }
    OptionParser.new do |parser|
      parser.on("--formulae FORMULAE") { |value| options[:formulae] = value }
      parser.on("--repository REPOSITORY") { |value| options[:repository] = value }
    end.parse!(argv)
    raise Error, "Unexpected arguments: #{argv.join(" ")}" unless argv.empty?

    options
  end

  def publish_options(argv, env)
    options = {
      repository:  nil,
      sha:         nil,
      output_path: nil,
      token:       env["HOMEBREW_GITHUB_API_TOKEN"],
    }
    OptionParser.new do |parser|
      parser.on("--repository REPOSITORY") { |value| options[:repository] = value }
      parser.on("--sha SHA") { |value| options[:sha] = value }
      parser.on("--output PATH") { |value| options[:output_path] = value }
    end.parse!(argv)
    raise Error, "Unexpected arguments: #{argv.join(" ")}" unless argv.empty?

    options
  end

  def main(argv: ARGV, env: ENV, runner: CommandRunner.new)
    command = argv.shift
    case command
    when "select-formulae"
      select_formulae(**select_options(argv), runner:)
    when "build-bottles"
      build_bottles(**build_options(argv), runner:, formula_service: HomebrewFormulaService.new)
    when "find-publish-run"
      find_publish_run(**publish_options(argv, env), runner:)
    else
      raise Error, "Usage: brew ruby scripts/bottle_workflow.rb " \
                   "<select-formulae|build-bottles|find-publish-run>"
    end
    0
  rescue Error, OptionParser::ParseError => e
    warn "::error::#{e.message}"
    1
  end
end

exit BottleWorkflow.main if __FILE__ == $PROGRAM_NAME
