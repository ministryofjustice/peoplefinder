require 'csv'

module CsvPublisher
  class UserBehaviorReport

    attr_reader :file, :dataset

    def initialize file = nil
      @file = file || Rails.root.join('tmp', 'reports', default_file_name).to_path
      @query = UserBehaviorQuery.new
    end

    def publish!
      @dataset = @query.data
      write! if @dataset.present?
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
      CSV.open(file, 'w') do |csv|
        csv << csv_header
        dataset.each do |rec|
          csv << csv_record(rec)
        end
      end
    end
  end
end
