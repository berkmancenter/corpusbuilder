module Finalizable
  extend ActiveSupport::Concern

  included do
    def on_finalize(&block)
      finalizer = -> (id) {
        self.instance_eval(&block)
      }

      ObjectSpace.define_finalizer(self, finalizer)
    end
  end
end
