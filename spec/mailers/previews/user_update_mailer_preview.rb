class UserUpdateMailerPreview < ActionMailer::Preview

  include PreviewHelper

  def new_profile_email
    UserUpdateMailer.new_profile_email(recipient, instigator)
  end

  def updated_profile_email
    UserUpdateMailer.updated_profile_email(recipient, instigator)
  end

  def deleted_profile_email
    UserUpdateMailer.deleted_profile_email(recipient.email, recipient.name, instigator)
  end
end
