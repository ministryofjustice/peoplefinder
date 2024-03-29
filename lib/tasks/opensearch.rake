# A collection of Rake tasks to facilitate importing data from your models into OpenSearch.
#
# To import the records from your `Article` model, run:
#
#     $ bundle exec rake environment opensearch:import:model CLASS='MyModel'
#
# Run this command to display usage instructions:
#
#     $ bundle exec rake -D opensearch
#
$stdout.sync = true
$stderr.sync = true

begin; require "ansi/progressbar"; rescue LoadError; end # rubocop:disable Lint/SuppressedException

namespace :opensearch do
  desc "import"
  task import: "import:model"

  namespace :import do
    import_model_desc = <<-DESC.gsub(/    /, "")
      Import data from your model (pass name as CLASS environment variable).

        $ rake environment opensearch:import:model CLASS='MyModel'

      Force rebuilding the index (delete and create):
        $ rake environment opensearch:import:model CLASS='Article' FORCE=y

      Customize the batch size:
        $ rake environment opensearch:import:model CLASS='Article' BATCH=100

      Set target index name:
        $ rake environment opensearch:import:model CLASS='Article' INDEX='articles-new'

      Pass an ActiveRecord scope to limit the imported records:
        $ rake environment opensearch:import:model CLASS='Article' SCOPE='published'
    DESC
    desc import_model_desc
    task model: :environment do
      if ENV["CLASS"].to_s == ""
        puts "=" * 90, "USAGE", "=" * 90, import_model_desc, ""
        exit(1)
      end

      klass = eval(ENV["CLASS"].to_s) # rubocop:disable Security/Eval
      begin
        total = klass.count
      rescue StandardError
        nil
      end

      begin
        pbar = ANSI::Progressbar.new(klass.to_s, total)
      rescue StandardError
        nil
      end
      pbar.__send__ :show if pbar

      unless ENV["DEBUG"]
        begin
          klass.__opensearch__.client.transport.logger.level = Logger::WARN
        rescue NoMethodError; end # rubocop:disable Lint/SuppressedException
        begin
          klass.__opensearch__.client.transport.tracer.level = Logger::WARN
        rescue NoMethodError; end # rubocop:disable Lint/SuppressedException
      end

      total_errors = klass.__opensearch__.import force: ENV.fetch("FORCE", false),
                                                 batch_size: ENV.fetch("BATCH", 1000).to_i,
                                                 index: ENV.fetch("INDEX", nil),
                                                 scope: ENV.fetch("SCOPE", nil) do |response|
        pbar.inc response["items"].size if pbar
        $stderr.flush
        $stdout.flush
      end
      pbar.finish if pbar

      puts "[IMPORT] #{total_errors} errors occurred" unless total_errors.zero?
      puts "[IMPORT] Done"
    end

    desc <<-DESC.gsub(/    /, "")
      Import all indices from `app/models` (or use DIR environment variable).

        $ rake environment opensearch:import:all DIR=app/models
    DESC
    task all: :environment do
      dir = ENV["DIR"].to_s != "" ? ENV["DIR"] : Rails.root.join("app/models")

      puts "[IMPORT] Loading models from: #{dir}"
      Dir.glob(File.join("#{dir}/**/*.rb")).each do |path|
        model_filename = path[/#{Regexp.escape(dir.to_s)}\/([^.]+).rb/, 1]

        next if model_filename.match(/^concerns\//i) # Skip concerns/ folder

        begin
          klass = model_filename.camelize.constantize
        rescue NameError
          require(path) ? retry : raise("Cannot load class '#{klass}'")
        end

        # Skip if the class doesn't have OpenSearch integration
        next unless klass.respond_to?(:__opensearch__)

        puts "[IMPORT] Processing model: #{klass}..."

        ENV["CLASS"] = klass.to_s
        Rake::Task["opensearch:import:model"].invoke
        Rake::Task["opensearch:import:model"].reenable
        puts
      end
    end
  end
end
