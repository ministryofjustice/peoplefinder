module BreadcrumbHelper

  def breadcrumbs(items, show_links: true)
    starts_with_home = items.first == Home.instance
    starts_with_root_team = items.first == Group.department
    render partial: 'shared/breadcrumbs',
      locals: {
        items: items,
        show_links: show_links,
        starts_with_home: starts_with_home,
        starts_with_root_team: starts_with_root_team
      }
  end

  def crumb_to(crumb, options = {})
    options = crumb_options(options)

    if crumb.is_a?(String) || !(options[:show_links])
      content_tag(:li, options) do
        crumb.to_s
      end
    else
      content_tag(:li, options) do
        link_to_breadcrumb_name_unless_current(
          crumb,
          options[:index],
          starts_with_home: options[:starts_with_home],
          starts_with_root_team: options[:starts_with_root_team]
        )
      end
    end
  end

  def crumb_options options
    crumb_keys = [:index, :starts_with_home, :starts_with_root_team, :show_links, :class, :style]
    options.assert_valid_keys(*crumb_keys)
    options[:class] = "breadcrumb-#{options[:index]}"
    options.slice(*crumb_keys)
  end

  def link_to_breadcrumb_name_unless_current(obj, index, starts_with_home: nil, starts_with_root_team: nil)
    index = adjust_breadcrumb_index(index, starts_with_home, starts_with_root_team)
    link_text = if index < 3 && obj.respond_to?(:short_name) && obj.short_name.present?
                  obj.short_name
                else
                  obj.name
                end

    html_options = obj.name == link_text ? {} : { title: obj.name }
    link_to_unless_current link_text, obj, html_options
  end

  def adjust_breadcrumb_index index, starts_with_home, starts_with_root_team
    if starts_with_home
      index - 1
    elsif starts_with_root_team
      index
    else
      index + 1
    end
  end
end
