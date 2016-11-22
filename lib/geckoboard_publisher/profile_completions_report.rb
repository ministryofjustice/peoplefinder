module GeckoboardPublisher
  class ProfileCompletionsReport < Report

    def fields
      [
        Geckoboard::StringField.new(:team, name: 'Team name'),
        Geckoboard::NumberField.new(:total, name: 'Total profiles'),
        Geckoboard::PercentageField.new(:with_photos, name: '% profiles with photos'),
        Geckoboard::PercentageField.new(:with_additional_info, name: '% profiles with Additional Info')
      ]
    end

    def items
      @items ||= parse Person.completions_per_top_level_team
    end

    private

    def parse items
      items.each do |item|
        total = item[:total].to_f
        item[:with_photos] = (item[:with_photos]/total).round(2)
        item[:with_additional_info] = (item[:with_additional_info]/total).round(2)
      end
    end

  end
end
