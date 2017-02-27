require 'csv'

module CsvPublisher
  class UserBehaviorReport
    extend SingleForwardable

    attr_reader :file, :query, :dataset

    def initialize file = nil
      @file = file || self.class.default_file_path
      @query = UserBehaviorQuery.new
    end

    def publish!
      @dataset = query.data
      write! if dataset.present?
    end
    def_single_delegator :new, :publish!, :publish!

    class << self

      def default_file_path
        Dir.mkdir(tmp_dir) unless Dir.exist? tmp_dir
        tmp_dir.join(default_file_name)
      end

      private

      def tmp_dir
        @tmp_dir ||= Rails.root.join('tmp', 'reports')
      end

      # e.g. peoplefinder_staging_user_behavior_report
      def default_file_name
        Rails.application.class.parent_name.underscore +
          '_' +
          (ENV['ENV'] || Rails.env).downcase +
          '_' +
          name.demodulize.underscore +
          '.csv'
      end
    end

    private

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
