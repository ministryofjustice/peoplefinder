require 'delegate'

class MarkMandatoryLabels < SimpleDelegator
  def label(method, text = nil, options = {}, &block)
    if text.is_a?(Hash)
      options = text
      text = nil
    end

    if presence_validated?(method)
      options[:class] = [options[:class], 'mandatory'].compact.join(' ')
    end

    __getobj__.label(method, text, options, &block)
  end

  private

  def presence_validated?(method)
    object.respond_to?(:mandates_presence_of?) &&
      object.mandates_presence_of?(method)
  end
end
