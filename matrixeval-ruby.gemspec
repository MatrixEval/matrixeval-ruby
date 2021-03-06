# frozen_string_literal: true
require_relative "lib/matrixeval/ruby/version"

Gem::Specification.new do |spec|
  spec.name = "matrixeval-ruby"
  spec.version = Matrixeval::Ruby::VERSION
  spec.authors = ["Hopper Gee"]
  spec.email = ["hopper.gee@hey.com"]

  spec.summary = "MatrixEval-Ruby"
  spec.description = "MatrixEval-Ruby"
  spec.homepage = "https://github.com/MatrixEval/matrixeval-ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.5.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/MatrixEval/matrixeval-ruby"
  spec.metadata["changelog_uri"] = "https://github.com/MatrixEval/matrixeval-ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  # spec.bindir = "exe"
  # spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "matrixeval", "~> 0.4.2"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
