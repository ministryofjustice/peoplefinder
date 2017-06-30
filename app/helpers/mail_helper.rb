module MailHelper

  APP_GUIDANCE_PAGE = 'https://intranet.justice.gov.uk/peoplefinder'.freeze

  def browser_warning
    content_tag(:p, class: 'browser-warning') do
      'Internet Explorer 6 and 7 users should copy and paste the link below into Firefox'
    end
  end

  def easy_copy_link_to url:
    content_tag(:div, style: 'padding: 10px 20px;') do
      link_to url_for(url), url_for(url), target: '_blank'
    end
  end

  def app_guidance
    content_tag(:p) do
      safe_join [
        'People Finder allows you to update any profile. ',
        'Find out more about how to use People Finder on the ',
        link_to_guidance,
        '.'
      ]
    end
  end

  def do_not_reply
    content_tag(:p, 'This email is automatically generated. Do not reply.')
  end

  private

  def link_to_guidance
    link_to('MoJ Intranet', APP_GUIDANCE_PAGE, target: '_blank')
  end

end
