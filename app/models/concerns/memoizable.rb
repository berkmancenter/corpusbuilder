module Memoizable
  extend ActiveSupport::Concern

  included do
    def memoized(&block)
      loc = caller_locations(1, 1).first
      @_memoized ||= {}
      @_memoized["#{loc.path}:#{loc.lineno}"] ||= -> {
        block.call
      }.call
    end

    def clear_memoized
      @_memoized = {}
    end
  end
end
