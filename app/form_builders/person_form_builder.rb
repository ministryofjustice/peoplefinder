class PersonFormBuilder < GovukElementsFormBuilder::FormBuilder

  LABEL_SCOPE = [:helpers, :label, :person].freeze

  def check_box(method, options = {}, checked_value = '1', unchecked_value = '0')
    @template.content_tag :div, class: 'form-group' do
      @template.label(@object_name, method, class: 'block-label selection-button-checkbox') do
        @template.check_box(@object_name, method.to_s, options, checked_value, unchecked_value) +
          label_t(method)
      end
    end
  end

  def text_field(attribute, options = {})
    if needed_for_completion? attribute
      options[:class] ||= []
      options[:class] << 'incomplete'
    end
    super
  end

  private

  def needed_for_completion?(field)
    object.respond_to?(:needed_for_completion?) &&
      object.needed_for_completion?(field)
  end

  def label_t attribute
    I18n.t(attribute, scope: LABEL_SCOPE)
  end

end
