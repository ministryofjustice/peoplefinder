module GovukElementsErrorsHelperExtensions

  def error_summary_list object
    content_tag(:ul, class: 'error-summary-list') do
      messages = error_summary_messages(object)
      messages.flatten.join('').html_safe
    end
  end

  def error_summary_messages object
    object.errors.attribute_names.map do |attribute|
      error_summary_message object, attribute
    end
  end

  def error_summary_message object, attribute
    if nested_attribute?(object, attribute)
      association = association_from_attribute(attribute)
      nested_attribute = association_attribute_from_attribute(attribute)
      map_association_error_tag(
        parent: object,
        association: association,
        attribute: nested_attribute
      ) do |error_tag, messages|
        messages << error_tag
      end
    else
      messages = object.errors.full_messages_for attribute
      messages.map do |message|
        object_prefixes = object_prefixes object
        link = link_to_error(object_prefixes, attribute)
        message.sub! default_label(attribute), localized_label(object_prefixes, attribute)
        content_tag(:li, content_tag(:a, message, href: link))
      end
    end
  end

  def object_prefixes object
    [underscore_name(object)]
  end

  def map_association_error_tag parent:, association:, attribute:, &_block
    parent.__send__(association).
      each_with_object([]).
      with_index do |(associated_object, memo), index|
        if associated_object.errors.key?(attribute) && block_given?
          yield error_tag_for_nested_attribute(associated_object, index, attribute), memo
        end
      end
  end

  def association_names object
    object.class.reflect_on_all_associations.map(&:name)
  end

  def association_from_attribute attribute
    attribute.to_s.split('.').first.pluralize.to_sym
  end

  def association_attribute_from_attribute attribute
    attribute.to_s.split('.')&.second&.to_sym
  end

  def nested_attribute? object, attribute
    association_attribute_from_attribute(attribute).present? &&
      association_names(object).include?(association_from_attribute(attribute))
  end

  def error_tag_for_nested_attribute object, index, attribute
    messages = object.errors.full_messages_for attribute
    messages.map do |message|
      association_name = object.class.name.downcase
      dom_id = dom_id_for_nested_error(
        association_name,
        index,
        attribute
      )
      message.sub! default_label(attribute), localized_label([association_name], attribute)
      content_tag(:li, content_tag(:a, message, href: "##{dom_id}"))
    end
  end

  def error_html_attributes form_object, attribute
    {
      class: ('error' if form_object.object.errors.key?(attribute)).to_s,
      id: dom_id_for_nested_error(form_object.object.class.name.downcase, form_object.index, attribute)
    }
  end

  private

  def dom_id_for_nested_error association_name, index, attribute
    ['error', association_name, index, attribute].join('_')
  end
end

module GovukElementsErrorsHelper
  singleton_class.prepend GovukElementsErrorsHelperExtensions
end
