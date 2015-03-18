require 'delegate'

module Peoplefinder
  class FormGroups < SimpleDelegator
    def form_group(method, options = {}, &block)
      classes = [options[:class], 'form-group'].compact
      if errors?(method)
        classes << 'gov-uk-field-error'
      elsif needed_for_completion?(method)
        classes << 'incomplete'
      end
      template.content_tag(:div, class: classes.join(' '), &block)
    end

  private

    def errors?(method)
      object.errors.include?(method)
    end

    def needed_for_completion?(method)
      object.respond_to?(:needed_for_completion?) &&
        object.needed_for_completion?(method)
    end
  end
end
