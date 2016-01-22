require 'delegate'

class FormGroups < SimpleDelegator
  def form_group(field, options = {}, &block)
    classes = [options[:class], 'form-group'].compact
    if errors?(field)
      classes << 'gov-uk-field-error'
    elsif needed_for_completion?(field)
      classes << 'incomplete'
    end
    template.content_tag(:div, class: classes.join(' '), &block)
  end

  private

  def errors?(field)
    object.errors.include?(field)
  end

  def needed_for_completion?(field)
    object.respond_to?(:needed_for_completion?) &&
      object.needed_for_completion?(field)
  end
end
