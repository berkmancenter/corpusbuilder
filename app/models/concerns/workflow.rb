module Workflow
  extend ActiveSupport::Concern

  included do
    def self.workflow(options)
      enum options

      column = options.keys.first
      states = options[column]

      states.each do |state|
        define_method("#{state}!") do
          workflow_update_state column, state
        end
      end

      def workflow_update_state(column, state)
        states = self.class.send column.to_s.pluralize
        update_attribute column, states[state]
        state.to_s
      end
    end
  end
end
