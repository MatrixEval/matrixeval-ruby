module Matrixeval
  module Ruby
    class Target < Matrixeval::Target

      def version
        Matrixeval::Ruby::VERSION
      end

      def matrixeval_yml_template_path
        Matrixeval::Ruby.root.join("lib/matrixeval/ruby/templates/matrixeval.yml")
      end

      def vector_key
        "ruby"
      end

      def env(context)
        {
          "BUNDLE_PATH" => "/bundle",
          "GEM_HOME" => "/bundle",
          "BUNDLE_APP_CONFIG" => "/bundle",
          "BUNDLE_BIN" => "/bundle/bin",
          "PATH" => "/app/bin:/bundle/bin:$PATH"
        }
      end

      def mounts(context)
        bundle_volume = bundle_volume(context)

        [
          "#{bundle_volume}:/bundle",
          "../gemfile_locks/#{context.id}:/app/Gemfile.lock"
        ]
      end

      def volumes(context)
        bundle_volume = bundle_volume(context)

        {
          bundle_volume => {
            "name" => bundle_volume
          }
        }
      end

      def gitignore_paths
        [
          ".matrixeval/gemfile_locks"
        ]
      end

      def support_commands
        [
          'ruby', 'rake', 'rails', 'rspec', 'bundle',
          'bin/rake', 'bin/rails', 'bin/rspec', 'bin/test'
        ]
      end

      def cli_example_lines
        [
          "",
          "Example:",
          "    matrixeval --all bundle install",
          "    matrixeval --ruby 3.0 rspec a_spec.rb",
          "    matrixeval --ruby 3.1 --active_model 7.0 rake test",
          "    matrixeval bash"
        ]
      end

      def create_files
        gemfile_lock_folder = Matrixeval.working_dir.join(".matrixeval/gemfile_locks")
        FileUtils.mkdir_p gemfile_lock_folder

        Context.all.each do |context|
          FileUtils.touch gemfile_lock_folder.join(context.id)
        end
      end

      private

      def bundle_volume(context)
        docker_image = context.main_variant.container.image
        "bundle_#{docker_image.gsub(/[^A-Za-z0-9]/,'_')}"
      end
    end
  end
end
