class Invitation < SimpleDelegator
  extend ActiveModel::Naming

  def update(attributes)
    __getobj__.update(attributes).tap { communicate_change }
  end

protected

  def communicate_change
    return unless declined?
    token = subject.tokens.create!
    ReviewMailer.request_declined(self, token).deliver
  end
end
