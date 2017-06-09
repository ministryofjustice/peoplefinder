require_relative 'sections/about_usage'

module Pages
  class Browse < Base
    set_url('/browse')
    set_url_matcher('/browse')

    element :page_title, '#content h1.cb-page-title'
    element :create_team_link, '.add-new-team'
    element :leader_profile_image, 'img.media-object'

    section :about_usage, Sections::AboutUsage, '.cb-about-usage'
  end
end
