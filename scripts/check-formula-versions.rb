# typed: strict
# frozen_string_literal: true

require "uri"

# Verifies that Homebrew resolves each formula to the version in its GitHub release tag.
module FormulaVersionCheck
  class Error < StandardError; end

  module_function

  def expected_version(formula)
    url = formula.stable.url
    release_match = url.match(%r{/releases/download/([^/]+)/})
    raise Error, "#{formula.full_name}: URL does not contain a GitHub release tag: #{url}" unless release_match

    release_tag = URI.decode_www_form_component(release_match[1])
    version_match = release_tag.match(/([0-9]+(?:\.[0-9]+)+)\z/)
    raise Error, "#{formula.full_name}: release tag does not end in a version: #{release_tag}" unless version_match

    version_match[1]
  end

  def main(names = ARGV)
    raise Error, "No formulae provided." if names.empty?

    problems = names.filter_map do |name|
      formula = Formula[name]
      expected = expected_version(formula)
      actual = formula.version.to_s
      next if actual == expected

      "#{formula.full_name}: expected #{expected} from its release tag, but Homebrew resolved #{actual}"
    end

    unless problems.empty?
      problems.each { |problem| warn problem }
      return 1
    end

    puts "Verified versions for #{names.length} formulae."
    0
  rescue Error => e
    warn e.message
    1
  end
end

exit FormulaVersionCheck.main if __FILE__ == $PROGRAM_NAME
