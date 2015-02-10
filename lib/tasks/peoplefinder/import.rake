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
  end
end
