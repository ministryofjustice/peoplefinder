module Peoplefinder
  class FormBuilder < ActionView::Helpers::FormBuilder
    attr_reader :template # It's hidden in an instance variable
  end
end
