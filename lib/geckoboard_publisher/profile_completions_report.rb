module GeckoboardPublisher
  class ProfileCompletionsReport < Report

    def fields
      [
        Geckoboard::StringField.new(:date, name: 'Name'),
        Geckoboard::NumberField.new(:create, name: 'Total'),
        Geckoboard::NumberField.new(:update, name: 'With photos'),
        Geckoboard::NumberField.new(:destroy, name: 'With Additional Info')
      ]
    end

    def items
      @items ||= Person.completion_per_top_level_teams
    end

  end
end
