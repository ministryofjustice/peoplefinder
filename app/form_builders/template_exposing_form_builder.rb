class TemplateExposingFormBuilder < ActionView::Helpers::FormBuilder
  attr_reader :template # It's hidden in an instance variable
end
