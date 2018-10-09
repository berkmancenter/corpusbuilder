require "benchmark"

module Benchmarkable
  extend ActiveSupport::Concern

  included do
    def time(name, print_start = false, &block)
      ret = nil

      Rails.logger.info "Starting #{name}".colorize(:red) if print_start

      stats = Benchmark.measure { ret = block.call }

      Rails.logger.info "(#{stats.total * 1000}ms)".colorize(:magenta) + " #{name}".colorize(:red)

      ret
    end
  end
end
