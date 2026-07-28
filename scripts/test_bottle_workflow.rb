# typed: strict
# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"

require_relative "bottle_workflow"

# Test doubles and test cases intentionally share this regression test file.
# rubocop:disable Style/OneClassPerFile

# Records external command requests and returns configured responses.
class FakeRunner
  attr_reader :capture_commands, :captured_tokens, :run_commands, :success_commands

  def initialize(captures: {}, successes: {})
    @captures = captures
    @successes = successes
    @capture_commands = []
    @captured_tokens = []
    @run_commands = []
    @success_commands = []
  end

  def capture!(*command)
    @capture_commands << command
    @captured_tokens << ENV.fetch("GH_TOKEN", nil)
    @captures.fetch(command) { raise "Unexpected captured command: #{command.inspect}" }
  end

  def run!(*command)
    @run_commands << command
  end

  def success?(*command, quiet: false)
    @success_commands << [command, quiet]
    @successes.fetch(command, false)
  end
end

# Supplies deterministic formula metadata to the build orchestration tests.
class FakeFormulaService
  def initialize(order:, requirements: {}, identities: {})
    @order = order
    @requirements = requirements
    @identities = identities
  end

  def order(_names)
    @order
  end

  def unsatisfied_requirement_messages(name)
    @requirements.fetch(name, [])
  end

  def identity(name)
    @identities.fetch(name)
  end
end

# Verifies build command executables without installing, testing, or bottling a formula.
class HomebrewExecutableProbeRunner < BottleWorkflow::CommandRunner
  attr_reader :commands

  def initialize
    super
    @commands = []
  end

  def run!(*command)
    probe(command)
  end

  def success?(*command, quiet: false)
    probe(command)
    false
  end

  private

  def probe(command)
    @commands << command
    capture!(command.first, "--version")
  end
end

# Tests the workflow decisions and external command orchestration.
class BottleWorkflowTest < Minitest::Test
  def setup
    @root = Pathname(Dir.mktmpdir("bottle-workflow-test."))
    @output = @root/"github-output"
    @output.write("")
  end

  def teardown
    FileUtils.rm_rf(@root)
  end

  def test_manual_selection_uses_requested_formulae
    options = selection_options(
      event_name:         "workflow_dispatch",
      requested_formulae: "block/tap/stoic, block/tap/radiography,block/tap/stoic",
    )

    selected = BottleWorkflow.select_formulae(**options, runner: FakeRunner.new, root: @root)

    assert_equal ["block/tap/stoic", "block/tap/radiography"], selected
    assert_equal "value=block/tap/stoic,block/tap/radiography\n", @output.read
  end

  def test_manual_selection_defaults_to_every_formula
    formula_dir = @root/"Formula"
    formula_dir.mkpath
    (formula_dir/"stoic.rb").write("")
    (formula_dir/"anchors.rb").write("")
    options = selection_options(event_name: "workflow_dispatch", requested_formulae: "")

    selected = BottleWorkflow.select_formulae(**options, runner: FakeRunner.new, root: @root)

    assert_equal ["block/tap/anchors", "block/tap/stoic"], selected
    assert_equal "value=block/tap/anchors,block/tap/stoic\n", @output.read
  end

  def test_pull_request_selection_ignores_workflow_changes
    command = git_diff_command
    runner = FakeRunner.new(captures: { command => ".github/workflows/build-bottles.yml\n" })

    selected = BottleWorkflow.select_formulae(**selection_options, runner:, root: @root)

    assert_empty selected
    assert_equal "value=\n", @output.read
  end

  def test_pull_request_selection_returns_added_modified_and_renamed_formulae
    command = git_diff_command
    runner = FakeRunner.new(
      captures: {
        command => "Formula/stoic.rb\nFormula/radiography.rb\nREADME.md\nFormula/stoic.rb\n",
      },
    )

    selected = BottleWorkflow.select_formulae(**selection_options, runner:, root: @root)

    assert_equal ["block/tap/stoic", "block/tap/radiography"], selected
  end

  def test_build_orders_formulae_and_runs_bottle_commands
    stoic = "block/tap/stoic"
    radiography = "block/tap/radiography"
    brew = HOMEBREW_BREW_FILE.to_s
    runner = FakeRunner.new(successes: { [brew, "list", "--formula", "--versions", radiography] => true })
    formula_service = FakeFormulaService.new(
      order:      [stoic, radiography],
      identities: {
        stoic       => ["stoic", "0.9.1"],
        radiography => ["radiography", "2.9"],
      },
    )
    BottleWorkflow.build_bottles(
      formulae:        "#{radiography},#{stoic}",
      repository:      "block/homebrew-tap",
      runner:,
      formula_service:,
    )

    assert_equal [
      [brew, "install", "--build-bottle", "--no-ask", stoic],
      [brew, "test", stoic],
      [
        brew, "bottle", "--json",
        "--root-url=https://github.com/block/homebrew-tap/releases/download/stoic-0.9.1", stoic
      ],
      [brew, "uninstall", "--formula", "--force", radiography],
      [brew, "install", "--build-bottle", "--no-ask", radiography],
      [brew, "test", radiography],
      [
        brew, "bottle", "--json",
        "--root-url=https://github.com/block/homebrew-tap/releases/download/radiography-2.9", radiography
      ],
    ], runner.run_commands
    assert_equal [
      [[brew, "list", "--formula", "--versions", stoic], true],
      [[brew, "list", "--formula", "--versions", radiography], true],
    ], runner.success_commands
  end

  def test_build_skips_formulae_with_unsatisfied_requirements
    runner = FakeRunner.new
    formula_service = FakeFormulaService.new(
      order:        ["block/tap/qrgo"],
      requirements: { "block/tap/qrgo" => ["The arm64 architecture is required.", "This formula requires macOS."] },
    )
    stdout, = capture_io do
      BottleWorkflow.build_bottles(
        formulae:        "block/tap/qrgo",
        repository:      "block/homebrew-tap",
        runner:,
        formula_service:,
      )
    end

    assert_includes stdout, "Skipping block/tap/qrgo on this runner:"
    assert_includes stdout, "This formula requires macOS."
    assert_empty runner.run_commands
  end

  def test_build_commands_use_an_invocable_homebrew_executable
    formula = "block/tap/stoic"
    runner = HomebrewExecutableProbeRunner.new
    formula_service = FakeFormulaService.new(
      order:      [formula],
      identities: { formula => ["stoic", "0.9.1"] },
    )

    BottleWorkflow.build_bottles(
      formulae:        formula,
      repository:      "block/homebrew-tap",
      runner:,
      formula_service:,
    )

    assert_equal 4, runner.commands.length
    assert runner.commands.all? { |command| command.first == HOMEBREW_BREW_FILE.to_s }
  end

  def test_find_publish_run_ignores_direct_pushes
    runner = FakeRunner.new(captures: { pulls_command => "[]" })

    result = BottleWorkflow.find_publish_run(**publish_options, runner:)

    assert_nil result
    assert_empty @output.read
  end

  def test_find_publish_run_ignores_pull_requests_without_formula_changes
    runner = FakeRunner.new(
      captures: {
        pulls_command => JSON.generate([merged_pull_request]),
        files_command => JSON.generate([
          { "status" => "added", "filename" => ".github/workflows/build-bottles.yml" },
        ]),
      },
    )

    result = BottleWorkflow.find_publish_run(**publish_options, runner:)

    assert_nil result
    assert_equal [pulls_command, files_command], runner.capture_commands
    assert_empty @output.read
  end

  def test_find_publish_run_fails_when_changed_files_may_be_truncated
    files = Array.new(100) do |index|
      { "status" => "modified", "filename" => "docs/file-#{index}.md" }
    end
    runner = FakeRunner.new(
      captures: {
        pulls_command => JSON.generate([merged_pull_request]),
        files_command => JSON.generate(files),
      },
    )

    error = assert_raises(BottleWorkflow::Error) do
      BottleWorkflow.find_publish_run(**publish_options, runner:)
    end

    assert_equal "Pull request #131 has at least 100 changed files; its formula changes cannot be determined safely.",
                 error.message
    assert_empty @output.read
  end

  def test_find_publish_run_uses_exact_reviewed_head_with_bottle_artifacts
    previous_token = ENV.fetch("GH_TOKEN", nil)
    runner = FakeRunner.new(
      captures: {
        pulls_command          => JSON.generate([merged_pull_request]),
        files_command          => JSON.generate([{ "status" => "modified", "filename" => "Formula/stoic.rb" }]),
        runs_command           => JSON.generate({ "workflow_runs" => [{ "id" => 456 }] }),
        artifacts_command(456) => JSON.generate({
          "artifacts" => [
            { "name" => "unrelated", "expired" => false },
            { "name" => "bottles_ubuntu-latest", "expired" => false },
          ],
        }),
      },
    )

    result = BottleWorkflow.find_publish_run(**publish_options, runner:)

    assert_equal 456, result
    assert_equal "run_id=456\n", @output.read
    assert_equal ["test-token"] * 4, runner.captured_tokens
    if previous_token
      assert_equal previous_token, ENV.fetch("GH_TOKEN", nil)
    else
      assert_nil ENV.fetch("GH_TOKEN", nil)
    end
  end

  def test_find_publish_run_fails_without_a_successful_exact_head_build
    runner = FakeRunner.new(
      captures: {
        pulls_command => JSON.generate([merged_pull_request]),
        files_command => JSON.generate([{ "status" => "modified", "filename" => "Formula/stoic.rb" }]),
        runs_command  => JSON.generate({ "workflow_runs" => [] }),
      },
    )

    error = assert_raises(BottleWorkflow::Error) do
      BottleWorkflow.find_publish_run(**publish_options, runner:)
    end

    assert_includes error.message, "No successful bottle build found for pull request #131 at reviewed-sha"
  end

  def test_find_publish_run_fails_without_retained_bottle_artifacts
    runner = FakeRunner.new(
      captures: {
        pulls_command          => JSON.generate([merged_pull_request]),
        files_command          => JSON.generate([{ "status" => "modified", "filename" => "Formula/stoic.rb" }]),
        runs_command           => JSON.generate({ "workflow_runs" => [{ "id" => 456 }] }),
        artifacts_command(456) => JSON.generate({
          "artifacts" => [{ "name" => "bottles_ubuntu-latest", "expired" => true }],
        }),
      },
    )

    error = assert_raises(BottleWorkflow::Error) do
      BottleWorkflow.find_publish_run(**publish_options, runner:)
    end

    assert_equal "Bottle build 456 has no bottle artifacts.", error.message
  end

  private

  def selection_options(overrides = {})
    {
      event_name:         "pull_request",
      requested_formulae: "",
      base_ref:           "main",
      output_path:        @output.to_s,
    }.merge(overrides)
  end

  def git_diff_command
    ["git", "diff", "--diff-filter=AMR", "--name-only", "origin/main...HEAD", "--", "Formula/*.rb"]
  end

  def publish_options
    {
      repository:  "block/homebrew-tap",
      sha:         "merge-sha",
      output_path: @output.to_s,
      token:       "test-token",
    }
  end

  def merged_pull_request
    {
      "number"    => 131,
      "merged_at" => "2026-07-24T00:00:00Z",
      "head"      => { "sha" => "reviewed-sha" },
    }
  end

  def pulls_command
    ["gh", "api", "repos/block/homebrew-tap/commits/merge-sha/pulls"]
  end

  def files_command
    ["gh", "api", "repos/block/homebrew-tap/pulls/131/files?per_page=100"]
  end

  def runs_command
    [
      "gh", "api",
      "repos/block/homebrew-tap/actions/workflows/build-bottles.yml/runs" \
      "?head_sha=reviewed-sha&event=pull_request&status=success&per_page=1"
    ]
  end

  def artifacts_command(run_id)
    ["gh", "api", "repos/block/homebrew-tap/actions/runs/#{run_id}/artifacts?per_page=100"]
  end
end

# Exercises the narrow boundary with Homebrew's Ruby formula API.
class HomebrewFormulaServiceTest < Minitest::Test
  def setup
    @service = BottleWorkflow::HomebrewFormulaService.new
  end

  def test_orders_selected_formula_dependencies_first
    assert_equal [
      "block/tap/stoic",
      "block/tap/radiography",
    ], @service.order(["block/tap/radiography", "block/tap/stoic"])
  end

  def test_returns_formula_identity
    assert_equal ["stoic", "0.9.1"], @service.identity("block/tap/stoic")
  end

  def test_reports_platform_requirements
    skip "Linux-specific assertion" unless RUBY_PLATFORM.include?("linux")

    messages = @service.unsatisfied_requirement_messages("block/tap/qrgo")

    refute_empty messages
    assert messages.any? { |message| message.include?("macOS") }
  end
end

# rubocop:enable Style/OneClassPerFile
