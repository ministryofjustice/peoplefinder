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
# {"count"=>"18013", "event_date"=>"2016-09-09 00:00:00", "event"=>"create"}
# {"count"=>"1", "event_date"=>"2016-09-10 00:00:00", "event"=>"update"}
# {"count"=>"1", "event_date"=>"2016-09-15 00:00:00", "event"=>"update"}
# {"count"=>"2", "event_date"=>"2016-10-10 00:00:00", "event"=>"create"}
# {"count"=>"3", "event_date"=>"2016-10-14 00:00:00", "event"=>"update"}
# {"count"=>"3", "event_date"=>"2016-10-17 00:00:00", "event"=>"create"}
# {"count"=>"2", "event_date"=>"2016-10-21 00:00:00", "event"=>"update"}
# {"count"=>"76", "event_date"=>"2016-11-02 00:00:00", "event"=>"create"}
# {"count"=>"76", "event_date"=>"2016-11-02 00:00:00", "event"=>"destroy"}
# {"count"=>"5", "event_date"=>"2016-11-03 00:00:00", "event"=>"create"}
# {"count"=>"5", "event_date"=>"2016-11-03 00:00:00", "event"=>"destroy"}
# {"count"=>"1", "event_date"=>"2016-11-05 00:00:00", "event"=>"update"}
# {"count"=>"1", "event_date"=>"2016-11-07 00:00:00", "event"=>"destroy"}
# {"count"=>"3", "event_date"=>"2016-11-07 00:00:00", "event"=>"update"}
# # for each date create one record

      items = []
      results.each do |row|
        find_or_add_set(items, row)
      end
      items
    end

    def find_or_add_set items, row
      found = false
      items.each do |item|
        if found || item[:date] == row['event_date'].to_date.iso8601
          item[row['event'].to_sym] = row['count'].to_i if item[:date] == row['event_date'].to_date.iso8601
          found = true
        end
      end
      items << { date: row['event_date'].to_date.iso8601, row['event'].to_sym => row['count'].to_i } if not found
      items
    end

  end
end
