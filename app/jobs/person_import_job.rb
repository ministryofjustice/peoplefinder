class PersonImportJob < ActiveJob::Base

  #
  # The creation of people as initiated by the CSV uploader
  # '/admin/person_uploads/new', may exceed server timeout
  # limits (set by WEB_TIMEOUT,RACK_TIMEOUT) and so needs
  # to be performed asynchronously
  #

  queue_as :high_priority

  def queue_name
    'person_import'
  end

  attr_reader :serialized_people

  def perform(serialized_people, creation_options={})
    @serialized_people = serialized_people
    @creation_options = creation_options
    people.each do |person|
      PersonCreator.new(person, nil).create!
    end
    people.length
  end

  def max_run_time
    20.minutes
  end

  def max_attempts
    3
  end

  def destroy_failed_jobs?
    false
  end

private

  def people
    records = PersonCsvParser.new(serialized_people).records
    @people ||= records.map do |record|
      Person.new(@creation_options.merge(clean_fields(record.fields)))
    end
  end

  def clean_fields(hash)
    hash.merge(email: EmailExtractor.new.extract(hash[:email]))
  end

end