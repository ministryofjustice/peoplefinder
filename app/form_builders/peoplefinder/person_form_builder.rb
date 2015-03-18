module Peoplefinder
  module PersonFormBuilder
    #
    # Because Rails is gross and defies composition, we can only decorate a
    # form builder by passing it something that responds to new
    #
    def new(*args, &blk)
      Peoplefinder::MarkMandatoryLabels.new(
        ActionView::Helpers::FormBuilder.new(*args, &blk))
    end
    module_function :new
  end
end
