module GeckoboardPublisher
  class ProfilesPercentageReport < Report

    def fields
      [
        Geckoboard::NumberField.new(:total, name: 'Total'),
        Geckoboard::PercentageField.new(:with_photos, name: 'With Photos'),
        Geckoboard::PercentageField.new(:with_additional_info, name: 'With Additional Info'),
        Geckoboard::PercentageField.new(:not_in_team, name: 'Not in any team nor MoJ'),
        Geckoboard::PercentageField.new(:not_in_subteam, name: 'Not in a subteam - i.e. in MoJ'),
        Geckoboard::PercentageField.new(:not_in_tip_team, name: 'Not in a branch tip team - e.g. at Agency level')
      ]
    end

    def items
      setup
      [
        {
          with_photos: @with_photos,
          with_additional_info: @with_additional_info,
          not_in_team: @not_in_team,
          not_in_subteam: @not_in_subteam,
          not_in_tip_team: @not_in_tip_team
        }
      ]
    end

    private

    def setup
      percentage = PercentageOfTotal.new(Person)
      @with_photos ||= percentage.value(:photo_profiles)
      @with_additional_info ||= percentage.value(:additional_info_profiles)
      @not_in_team ||= percentage.value(:not_in_team)
      @not_in_subteam ||= percentage.value(:not_in_subteam)
      @not_in_tip_team ||= percentage.value(:not_in_tip_team)
    end

    class PercentageOfTotal
      def initialize model_klass
        @model_klass = model_klass
        @total = model_klass.count.to_f
      end

      def value scope
        count = @model_klass.__send__(scope).count
        (count/@total).round(2)
      end
    end
  end

end
