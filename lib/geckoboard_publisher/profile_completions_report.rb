module GeckoboardPublisher
  class ProfileCompletionsReport < Report

    def fields
      [
        Geckoboard::StringField.new(:team, name: 'Team name'),
        Geckoboard::NumberField.new(:total, name: 'Total profiles'),
        Geckoboard::NumberField.new(:with_photos, name: 'Profiles with photos'),
        Geckoboard::NumberField.new(:with_additional_info, name: 'Profiles with Additional Info')
      ]
    end

    def items
      @items ||= Person.completion_per_top_level_team
    end

  end
end
