require "benchmark"
require 'term/ansicolor'
include Term::ANSIColor

module Benchmarkable
  extend ActiveSupport::Concern

  included do
    def time(name, &block)
      ret = nil

      stats = Benchmark.measure { ret = block.call }

      Rails.logger.info magenta("(#{stats.total * 1000}ms)") + red(" #{name}")

      ret
    end
  end
end
