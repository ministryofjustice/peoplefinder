module GeckoboardPublisher
  class ProfilesChangedReport < Report

    attr_accessor :limit

    def initialize
      @limit = 500
      @items = nil
      super
    end

    def fields
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:create, name: 'Added'),
        Geckoboard::NumberField.new(:update, name: 'Edited'),
        Geckoboard::NumberField.new(:destroy, name: 'Deleted')
      ]
    end

    def items
      @items ||= parse Person.profile_events
    end

    private

    def parse pgresult
      @sets = []
      pgresult.each do |row|
        find_or_create_set(row)
      end
      @sets.drop(limit_diff)
    end

    def limit_diff
      [0, @sets.size - limit].max
    end

    def template date, options = {}
      { date: date.to_date.iso8601,
        create: options[:create] || 0,
        update: options[:update] || 0,
        destroy: options[:destroy] || 0
      }
    end

    def find_or_create_set row
      @sets.each do |set|
        return set[row['event'].to_sym] = row['count'].to_i if set[:date] == row['event_date'].to_date.iso8601
      end
      @sets << template(row['event_date'], row['event'].to_sym => row['count'].to_i)
    end
  end
end
