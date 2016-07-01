require 'yaml'

class PersonImportJob < ActiveJob::Base

  #
  # The creation of people as initiated by the CSV uploader
  # '/admin/person_uploads/new', may exceed server timeout
  # limits (set by WEB_TIMEOUT,RACK_TIMEOUT, 14 secs currently)
  # and so needs to be performed asynchronously
  #

  queue_as :person_import

  def perform(serialized_people, serialized_group_ids)
    @serialized_people = serialized_people
    @serialized_group_ids = serialized_group_ids
    people.each do |person|
      PersonCreator.new(person, nil).create!
    end

    people.length
  end

  def max_attempts
    3
  end

  def max_run_time
    10.minutes
  end

  def destroy_failed_jobs?
    false
  end

  private

  def creation_options
    { groups: PersonCsvImporter.deserialize_group_ids(@serialized_group_ids) }
  end

  def people
    records = PersonCsvParser.new(@serialized_people).records
    @people ||= records.map do |record|
      Person.new(creation_options.merge(PersonCsvImporter.clean_fields(record.fields)))
    end
  end

end
