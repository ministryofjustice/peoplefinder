class PasswordResetMailingJob < ActiveJob::Base
  queue_as :password_reset

  def perform(email)
    reset = PasswordReset.new(email: email)
    AdminUserMailer.password_reset(reset).deliver
  end
end
