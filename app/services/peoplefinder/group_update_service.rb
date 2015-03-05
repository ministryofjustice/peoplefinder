require 'peoplefinder'

module Peoplefinder
  class GroupUpdateService
    def initialize(group:, person_responsible:)
      @group = group
      @person_responsible = person_responsible
    end

    def update(params)
      @group.update(params)
    end
  end
end
