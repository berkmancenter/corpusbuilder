require "benchmark"
require 'term/ansicolor'
include Term::ANSIColor

module Benchmarkable
  extend ActiveSupport::Concern

  included do
    def time(name, print_start = false, &block)
      ret = nil

      Rails.logger.info red("Starting #{name}") if print_start

      stats = Benchmark.measure { ret = block.call }

      Rails.logger.info magenta("(#{stats.total * 1000}ms)") + red(" #{name}")

      ret
    end
  end
end
