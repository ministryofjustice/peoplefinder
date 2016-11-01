module GeckoboardPublisher
  class TotalProfilesReport < Report

    def initialize
      super
    end

    def fields
      [
        Geckoboard::NumberField.new(:count, name: 'Count'),
        Geckoboard::DateField.new(:created_at, name: 'Created'),
      ]
    end

    def items
      parse Person.total_profiles_by_day
    end

    private

    def parse results
      items = []
      results.each do |created_at, count|
        items << { created_at: created_at.to_date.iso8601.to_s, count: count }
      end
      items
    end

  end
end