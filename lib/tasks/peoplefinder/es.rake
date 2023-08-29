namespace :peoplefinder do
  namespace :es do
    desc "recreate opensearch index for person model"
    task index_people: :environment do
      sh("rake environment opensearch:import:model CLASS=\'Person\' FORCE=\'y\'")
    end
  end
end
