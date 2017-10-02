class PersonSerializer < ActiveModel::Serializer
  include ActionView::Helpers::AssetUrlHelper

  attributes(
    :email,
    :name,
    :team,
    :completion_score
  )

  link(:profile) { person_url(object) }
  link(:edit_profile) { edit_person_url(object) }
  link(:profile_image_url) { object.profile_image.try(:small).try(:url) }

  def team
    object.memberships[0].to_s
  end
end
