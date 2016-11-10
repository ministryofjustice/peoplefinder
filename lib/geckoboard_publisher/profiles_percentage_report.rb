module GeckoboardPublisher
  class ProfilesPercentageReport < Report

    def fields
      [
        Geckoboard::NumberField.new(:total, name: 'Total'),
        Geckoboard::PercentageField.new(:with_photos, name: 'With Photos'),
        Geckoboard::PercentageField.new(:with_additional_info, name: 'With Additional Info'),
        Geckoboard::PercentageField.new(:not_in_team, name: 'Not in any team nor MoJ'),
        Geckoboard::PercentageField.new(:not_in_subteam, name: 'Not in a subteam - i.e. in MoJ')
      ]
    end

    def items
      setup
      [
        {
          total: @total,
          with_photos: @with_photos,
          with_additional_info: @with_additional_info,
          not_in_team: @not_in_team,
          not_in_subteam: @not_in_subteam
        }
      ]
    end

    private

    def setup
      @total ||= Person.count
      @with_photos ||= (Person.photo_profiles.count.to_f/@total).round(2)
      @with_additional_info ||= (Person.additional_info_profiles.count.to_f/@total).round(2)
      @not_in_team ||= (Person.not_in_team.count.to_f/@total).round(2)
      @not_in_subteam ||= (Person.not_in_subteam.count.to_f/@total).round(2)
    end
  end

end
