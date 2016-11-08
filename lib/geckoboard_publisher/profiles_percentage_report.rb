module GeckoboardPublisher
  class ProfilesPercentageReport < Report

    def fields
      [
        Geckoboard::NumberField.new(:total, name: 'Total'),
        Geckoboard::PercentageField.new(:with_photos, name: 'With Photos'),
        Geckoboard::PercentageField.new(:with_additional_info, name: 'With Additional Info')
      ]
    end

    def items
      setup
      [
        {
          total: @total,
          with_photos: @with_photos,
          with_additional_info: @with_additional_info
        }
      ]
    end

    private

    def setup
      @total = Person.total_profiles.to_f
      @with_photos = (Person.total_photo_profiles.to_f/@total).round(2)
      @with_additional_info = (Person.total_additional_info_profiles.to_f/@total).round(2)
    end
  end

end
