require "csv"
require "benchmark"

module DataCopyable
  extend ActiveSupport::Concern

  included do
    def self.copy_data(table_name, column_names = nil, &block)
      if column_names.nil?
        column_names = table_name
        table_name = self.table_name
      end

      connection = self.connection.raw_connection
      copier = Copier.new(connection)

      sql = "COPY #{table_name} (#{column_names.join(', ')}) FROM STDIN CSV"

      stats = Benchmark.measure do
        connection.copy_data sql do
          block.call(copier)
        end
      end

      Rails.logger.info "(#{stats.total * 1000}ms)".colorize(:magenta) + "  " + sql.colorize(:cyan)
      Rails.logger.info "#{copier.count} rows copied".colorize(:cyan)

      true
    end

    class Copier
      attr_accessor :connection, :count

      def initialize(connection)
        self.connection = connection
        self.count = 0
      end

      def put(data)
        connection.put_copy_data CSV.generate_line(data)
        self.count += 1
      end
    end
  end
end
