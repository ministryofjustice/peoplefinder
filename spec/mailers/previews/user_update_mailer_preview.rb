class UserUpdateMailerPreview < ActionMailer::Preview

  include PreviewHelper

  def new_profile_email
    UserUpdateMailer.new_profile_email(recipient, instigator.email)
  end

  def updated_profile_email
    @dirty ||= dirty_recipient
    UserUpdateMailer.updated_profile_email(
      @dirty,
      ProfileChangesPresenter.new(@dirty.all_changes).serialize,
      instigator.email
    )
  end

  def deleted_profile_email
    UserUpdateMailer.deleted_profile_email(recipient.email, recipient.given_name, instigator.email)
  end
end
