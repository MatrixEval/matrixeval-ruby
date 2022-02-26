# frozen_string_literal: true

require "test_helper"

class Matrixeval::TargetTest < MatrixevalTest

  def setup
    @target = Matrixeval::Ruby::Target.new

    Matrixeval::Config::YAML.stubs(:yaml).returns({})
    ruby_vector = Matrixeval::Vector.new("ruby", {"key" => "ruby", "main" => true})
    sidekiq_vector = Matrixeval::Vector.new("sidekiq", {"key" => "sidekiq"})
    rails_vector = Matrixeval::Vector.new("rails", {"key" => "rails"})
    ruby_3_variant = Matrixeval::Variant.new({"key" => "3.0", "container" => { "image" => "ruby:3.0" }}, ruby_vector)
    sidekiq_5_variant = Matrixeval::Variant.new(
      {
        "key" => "5.0",
        "env" => {"SIDEKIQ_VERSION" => "5.0.0"}
      }, sidekiq_vector)

    rails_6_variant = Matrixeval::Variant.new(
      {
        "key" => "6.1",
        "env" => {"RAILS_VERSION" => "6.1.0"}
      }, rails_vector)

    @context = Matrixeval::Context.new(
      main_variant: ruby_3_variant,
      rest_variants: [sidekiq_5_variant, rails_6_variant]
    )
  end

  def test_version
    assert_equal '0.4.0', @target.version
  end

  def test_matrixeval_yml_template_path
    assert_match %r(lib/matrixeval/ruby/templates/matrixeval.yml), @target.matrixeval_yml_template_path.to_s
  end

  def test_vector_key
    assert_equal "ruby", @target.vector_key
  end

  def test_env
    expected_env = {
      "BUNDLE_PATH" => "/bundle",
      "GEM_HOME" => "/bundle",
      "BUNDLE_APP_CONFIG" => "/bundle",
      "BUNDLE_BIN" => "/bundle/bin",
      "PATH" => "/app/bin:/bundle/bin:$PATH"
    }
    assert_equal expected_env, @target.env(@context)
  end

  def test_mounts
    expected_mounts = [
      "bundle_ruby_3_0:/bundle",
      "../gemfile_locks/ruby_3_0_rails_6_1_sidekiq_5_0:/app/Gemfile.lock"
    ]
    assert_equal expected_mounts, @target.mounts(@context)
  end

  def test_volumes
    expected_volumes = {
      "bundle_ruby_3_0" => {
        "name" => "bundle_ruby_3_0"
      }
    }
    assert_equal expected_volumes, @target.volumes(@context)
  end

  def test_gitignore_paths
    assert_equal [".matrixeval/gemfile_locks"], @target.gitignore_paths
  end

  def test_support_commands
    expected_commands = [
      'ruby', 'rake', 'rails', 'rspec', 'bundle',
      'bin/rake', 'bin/rails', 'bin/rspec', 'bin/test'
    ]
    assert_equal expected_commands, @target.support_commands
  end

  def test_cli_example_lines
    expected_example_lines = [
      "",
      "Example:",
      "    matrixeval --all bundle install",
      "    matrixeval --ruby 3.0 rspec a_spec.rb",
      "    matrixeval --ruby 3.1 --active_model 7.0 rake test",
      "    matrixeval bash"
    ]
    assert_equal expected_example_lines, @target.cli_example_lines
  end

  def test_create_files
    Matrixeval.stubs(:working_dir).returns(dummy_gem_working_dir)
    FileUtils.rm_rf(dummy_gem_working_dir.join(".matrixeval/gemfile_locks"))
    Matrixeval::Context.stubs(:all).returns([@context])

    @target.create_files

    assert File.exist?(dummy_gem_working_dir.join(".matrixeval/gemfile_locks/ruby_3_0_rails_6_1_sidekiq_5_0"))
  end

end
