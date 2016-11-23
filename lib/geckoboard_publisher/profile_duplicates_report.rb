module GeckoboardPublisher
  class ProfileDuplicatesReport < Report

    def fields
      [
        Geckoboard::StringField.new(:full_name, name: 'Duplicate name'),
        Geckoboard::NumberField.new(:count, name: 'No. of duplicates'),
        Geckoboard::StringField.new(:emails, name: 'email list (truncated)')
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
      add_set(row) unless update_set(row)
    end

    def add_set row
      @sets << { full_name: row['full_name'],
                  count: 1,
                  emails: row['email'].slice(0, MAX_STRING_LENGTH)
                }
    end

    def find_set full_name
      found = @sets.select do |set|
        set[:full_name] == full_name
      end
      found.first
    end

    def update_set row
      set = find_set row['full_name']
      return false if set.nil?
      set[:emails] = (set[:emails] + ', ' + row['email']).slice(0, MAX_STRING_LENGTH)
      set[:count] += 1
      true
    end

  end
end
