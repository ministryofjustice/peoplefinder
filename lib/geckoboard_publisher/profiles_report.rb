module GeckoboardPublisher
  class ProfilesReport < Report

    def fields
      [
        Geckoboard::NumberField.new(:total, name: 'Total'),
        Geckoboard::NumberField.new(:with_photos, name: 'With Photos'),
        Geckoboard::NumberField.new(:with_additional_info, name: 'With Additional Info')
      ]
    end

    def items
      [
        {
          total: Person.total_profiles,
          with_photos: Person.total_photo_profiles,
          with_additional_info: Person.total_additional_info_profiles
        }
      ]
    end

  end
end
