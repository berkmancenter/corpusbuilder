module Silenceable
  extend ActiveSupport::Concern

  included do
    def self.silently(&block)
      prevout = STDOUT.dup
      preverr = STDERR.dup

      begin
        #$stdout.reopen Rails.root.join("log", "silenced.log"), 'w'
        #$stderr.reopen Rails.root.join("log", "silenced.error.log"), 'w'

        block.call
      ensure
        #$stdout.reopen prevout
        #$stderr.reopen preverr
      end
    end

    def silently(&block)
      self.class.silently(&block)
    end
  end
end
