module Peoplefinder
  module PersonFormBuilder
    #
    # Because Rails is gross and defies composition, we can only decorate a
    # form builder by passing it something that responds to new
    #
    def new(*args, &blk)
      Peoplefinder::FormGroups.new(
        Peoplefinder::MarkMandatoryLabels.new(
          Peoplefinder::FormBuilder.new(*args, &blk)))
    end
    module_function :new
  end
end
