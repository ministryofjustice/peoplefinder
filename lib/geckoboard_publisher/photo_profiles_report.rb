module GeckoboardPublisher
  class PhotoProfilesReport < Report

    def fields
      [
        Geckoboard::NumberField.new(:count, name: 'Count'),
        Geckoboard::DateField.new(:photo_added_at, name: 'Photo Added')
      ]
    end

    def items
      parse Person.photo_profiles_by_day_added
    end

    private

    def parse results
      items = []
      results.each do |photo_added_at, count|
        items << { photo_added_at: photo_added_at.to_date.iso8601, count: count }
      end
      items
    end

  end
end
