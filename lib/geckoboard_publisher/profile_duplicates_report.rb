


module GeckoboardPublisher
  class ProfileDuplicatesReport < Report

    attr_accessor :limit

    def initialize
      @limit = 5000
      @items = nil
      super
    end

    def fields
      [
        Geckoboard::StringField.new(:full_name, name: 'Duplicate name'),
        Geckoboard::NumberField.new(:emails, name: 'email list')
      ]
    end

    def items
      @items ||= parse Person.duplicate_profiles
    end

    private

    def parse pgresult
      @sets = []
      pgresult.each do |row|
        find_or_create_set(row)
      end
      @sets
    end

    def find_or_create_set row
      @sets.each do |set|
        if set[:full_name] == row['full_name']
          return set[:emails] = set[:emails] + ', ' + row['email']
        end
      end
      @sets << { full_name: row['full_name'], emails: row['email'] }
    end
  end
end
