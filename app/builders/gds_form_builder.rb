class GDSFormBuilder < ActionView::Helpers::FormBuilder
  def text_area(method, options = {})
    with_label(method) {
      super(method, add_class(options, 'text'))
    }
  end

  def bold_label(method, text = nil, options = {})
    label(method, text, add_class(options, 'form-label-bold'))
  end

  def radio_buttons(method, values, &labeler)
    values.map { |value|
      label(method, value: value, class: 'block-label') {
        radio_button(method, value) + labeler.call(value)
      }
    }.join.html_safe
  end

  def button(value = nil, options = {})
    super(value, add_class(options, 'button'))
  end

  def with_label(method, &content)
    bold_label(method) + content.call
  end

  def add_class(options, klass)
    options.merge(class: [options[:class], klass].compact.join(' '))
  end
end
