namespace :peoplefinder do
  namespace :db do

    desc "drop all tables"
    task :clear => :environment do
      conn = ActiveRecord::Base.connection
      tables = conn.tables
      tables.each do |table|
        puts "...dropping #{table}"
        conn.drop_table(table, force: :cascade)
      end
    end

    desc "reset all column information"
    task :reset_column_information => :environment do
      conn = ActiveRecord::Base.connection
      tables = conn.tables
      tables.each do |table|
        next if ['schema_migrations','delayed_jobs'].include? table
        table.classify.constantize.reset_column_information
      end
    end

    desc "drop tables, migrate, seed and populate with demonstration data for development purposes"
    task :reload => [:environment, :clear] do
      puts '...migrating'
      Rake::Task['db:migrate'].invoke
      puts '...resetting column information' # required due to schema changes from migrations not being reflected in models
      Rake::Task['peoplefinder:db:reset_column_information'].invoke
      puts '...seeding'
      Rake::Task['db:seed'].invoke
      puts '...creating demonstration data'
      Rake::Task['peoplefinder:data:demo'].invoke
    end

  end
end
