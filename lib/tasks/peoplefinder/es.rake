namespace :peoplefinder do
  namespace :es do
    desc 'recreate elasticsearch index for person model'
    task :index_people => :environment do
      sh ("rake environment elasticsearch:import:model CLASS=\'Person\' FORCE=\'y\'")
    end
  end
end
