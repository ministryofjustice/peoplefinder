require 'csv'

module CsvPublisher
  class UserBehaviorReport

    attr_reader :file, :query, :dataset

    def initialize file = nil
      @file = file || Rails.root.join('tmp', 'reports', default_file_name)
      @query = UserBehaviorQuery.new
    end

    def publish!
      @dataset = query.data
      write! if dataset.present?
    end

    private

    # e.g. peoplefinder_staging_user_behavior_report
    def default_file_name
      Rails.application.class.parent_name.underscore +
        '_' +
        (ENV['ENV'] || Rails.env).downcase +
        '_' +
        self.class.name.demodulize.underscore +
        '.csv'
    end

    def csv_header
      dataset.first.keys
    end

    def csv_record record_hash
      csv_record = []
      record_hash.values.each_with_object([]) do |value|
        csv_record += [value]
      end
      csv_record
    end

    def write!
      CSV.open(file, 'w', write_headers: true, headers: csv_header) do |csv|
        dataset.each do |rec|
          csv << csv_record(rec)
        end
      end
      file # return pathname to published file
    end
  end
end
