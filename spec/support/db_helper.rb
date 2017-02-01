module SpecSupport
  module DbHelper
    def table_counts
      @conn = ActiveRecord::Base.connection
      tables = @conn.tables
      tables.each do |t|
        result = @conn.execute("select count(*) from #{t}")
        rec = result.first
        puts "#{t}: #{rec['count']}"
      end
    end
  end
end
