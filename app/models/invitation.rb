class Invitation < SimpleDelegator
  extend ActiveModel::Naming

  def update(attributes)
    __getobj__.update(attributes).tap { communicate_change }
  end

protected

  def communicate_change
    DeclineNotification.new(self).send if declined?
  end
end
