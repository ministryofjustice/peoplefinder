# == Schema Information
#
# Table name: queued_notifications
#
#  id                    :integer          not null, primary key
#  email_template        :string
#  session_id            :string
#  person_id             :integer
#  current_user_id       :integer
#  changes_json          :text
#  edit_finalised        :boolean          default(FALSE)
#  processing_started_at :datetime
#  sent                  :boolean          default(FALSE)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class QueuedNotification < ActiveRecord::Base

  GRACE_PERIOD = 15.minutes

  scope :unsent, -> { where(sent: false) }
  scope :unprocessed, -> { where(processing_started_at: nil) }

  belongs_to :person
  belongs_to :current_user, class_name: Person

  # expects an instance of PersonUpdater or PersonCreator to be passed as a parameter
  def self.queue!(updater)
    changes = ProfileChangesPresenter.new(updater.person.all_changes)
    email_template = updater.is_a?(PersonCreator) ? 'new_profile_email' : 'updated_profile_email'
    create!(email_template: email_template,
            session_id: updater.session_id,
            person_id: updater.person.id,
            current_user_id: updater.current_user&.id,
            changes_json: changes.serialize,
            edit_finalised: updater.edit_finalised?)
  end

  def changes_hash
    JSON.parse(changes_json)
  end

  # returns all the records for a grouped item returned by QueuedNotification.unsent_groups
  #
  def self.all_for_grouped_item(gi)
    where(session_id: gi.session_id,
      person_id: gi.person_id,
      current_user_id: gi.current_user_id,
      processing_started_at: nil).
      order(:id)
  end

  # Returns all the records for a grouped item after having datestamped the processing_started_at column.
  #
  # If the group is already being processed (i.e. the processed ), nil is returned.
  #
  def self.start_processing_grouped_item(gi)
    records = all_for_grouped_item(gi)
    if records.map(&:processing_started_at).uniq == [nil]
      ids = records.map(&:id)
      records.update_all(processing_started_at: Time.now.utc)
      QueuedNotification.where(id: ids)
    end
  end

  # This method retrieves one record for each group of notifications that:
  #  - are unsent and, their most recent record is older than the grace period
  #  - are unsent and finalised
  #
  def self.unsent_groups
    groups = unprocessed.select(:session_id, :person_id, :current_user_id).
             group(:session_id, :person_id, :current_user_id)
    groups.to_a.delete_if { |group| unfinalised_and_within_grace_period?(group) }
  end

  # this method returns true if the group is unsent AND the most recent record in the group is within the grace period
  def self.unfinalised_and_within_grace_period?(group)
    recs = where(session_id: group.session_id,
                      person_id: group.person_id,
                      current_user_id: group.current_user_id).order(:id)
    return false if recs.map(&:edit_finalised?).include?(true)
    return false if recs.last.created_at < GRACE_PERIOD.ago
    true
  end

  private_class_method :unfinalised_and_within_grace_period?
end
