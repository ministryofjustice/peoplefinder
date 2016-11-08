module GeckoboardPublisher
  class ProfilesChangedReport < Report

    def fields
      [
        Geckoboard::DateField.new(:date, name: 'Date'),
        Geckoboard::NumberField.new(:create, name: 'Added'),
        Geckoboard::NumberField.new(:update, name: 'Edited'),
        Geckoboard::NumberField.new(:destroy, name: 'Deleted')
      ]
    end

    def items
      parse Person.profile_events
    end

    private

    def parse results
      items = []
      results.each do |row|
        find_or_add_set(items, row)
      end
      items
    end

    def template date, options = {}
      { date: date,
        create: options[:create] || 0,
        update: options[:update] || 0,
        destroy: options[:destroy] || 0
      }
    end

    def find_or_add_set items, row
      found = false
      items.each do |item|
        break if found
        if item[:date] == row['event_date'].to_date.iso8601
          item[row['event'].to_sym] = row['count'].to_i if item[:date] == row['event_date'].to_date.iso8601
          found = true
        end
      end
      items << template(row['event_date'].to_date.iso8601, row['event'].to_sym => row['count'].to_i) unless found
      items
    end
  end
end
