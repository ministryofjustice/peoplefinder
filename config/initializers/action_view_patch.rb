# Allows GovukElementsFormBuilder to work in Rails 7
module ActionView
  class Base
    def add_error_to_html_tag!(html_tag, instance)
      GovukElementsFormBuilder::FormBuilder.send(:add_error_to_html_tag!, html_tag, instance)
    end
  end
end
