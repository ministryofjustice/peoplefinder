require 'csv'

module CsvPublisher
  class UserBehaviorReport
    extend SingleForwardable

    attr_reader :file, :query, :dataset

    FILE_EXTENSION = 'csv'.freeze

    def initialize
      @file = self.class.default_file_path
      @query = UserBehaviorQuery.new
    end

    def publish!
      @dataset = query.data
      write! if dataset.present?
    end
    def_single_delegator :new, :publish!, :publish!

    class << self

      def report_name
        name.demodulize.underscore
      end

      def default_file_path
        FileUtils.mkdir_p tmp_dir
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
          report_name +
          '.' +
          FILE_EXTENSION
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

    def save! file
      content = File.read(file)
      Report.where(name: self.class.report_name).delete_all
      Report.create!(name: self.class.report_name, content: content, extension: FILE_EXTENSION, mime_type: 'text/csv')
    end

    def write!
      CSV.open(file, 'w', write_headers: true, headers: csv_header) do |csv|
        dataset.each do |rec|
          csv << csv_record(rec)
        end
      end
      save!(file)
    end
  end
end
