class Invitation < SimpleDelegator
  extend ActiveModel::Naming

  def update(attributes)
    super.tap { communicate_change }
  end

protected

  def communicate_change
    DeclineNotificationJob.perform_later id if declined?
  end
end
