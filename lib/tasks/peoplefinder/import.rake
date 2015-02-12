namespace :peoplefinder do
  namespace :import do
    desc 'Check validity of CSV file before import'
    task :csv_check, [:path] => :environment do |_, args|
      if File.exist?(args[:path])
        importer = Peoplefinder::CsvPeopleImporter.new(File.new(args[:path]))
        if importer.valid?
          puts 'The given file is valid'
        else
          puts 'The given file has some errors:'
          importer.errors.each do |error|
            puts error
          end
        end
      else
        puts 'The given file doesn\'t exist'
      end
    end

    desc 'Import valid CSV file'
    task :csv_import, [:path] => :environment do |_, args|
      if File.exist?(args[:path])
        importer = Peoplefinder::CsvPeopleImporter.new(File.new(args[:path]))
        result = importer.import

        if result.nil?
          puts 'The given file is not valid, please run the csv check task'
        else
          puts "#{result} people imported"
        end
      else
        puts 'The given file doesn\'t exist'
      end
    end
  end
end
