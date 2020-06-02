require 'yaml'

class PersonImportJob < ApplicationJob

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
    create_people!
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

  # NOTE: if job fails part way through we do not want subsequent attempts
  # to create people already created as this hides the original error
  def create_people!
    people.each do |person|
      if Person.find_by(email: person.email)
        Rails.logger.warn "Person identified by email #{person.email} already exists. Skipping!"
      else
        PersonCreator.new(person: person,
                          current_user: nil,
                          state_cookie: StateManagerCookie.static_create_and_save).create!
      end
    end

    enqueue_group_completion_score_updates

    people.length
  end

  def enqueue_group_completion_score_updates
    creation_options[:groups].each do |group|
      UpdateGroupMembersCompletionScoreJob.perform_later(group)
    end
  end

  def creation_options
    {
      groups: PersonCsvImporter.deserialize_group_ids(@serialized_group_ids),
      skip_group_completion_score_updates: true
    }
  end

  def people
    @people ||= records.map do |record|
      Person.new(creation_options.merge(PersonCsvImporter.person_fields(record.fields))).tap do |person|
        person.memberships.first.role = record.fields[:role]
      end
    end
  end

  def records
    PersonCsvParser.new(@serialized_people).records
  end

end
