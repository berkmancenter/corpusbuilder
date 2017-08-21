module V1Base
  extend ActiveSupport::Concern

  included do
    format :json
    prefix :api
    version 'v1', using: :header, vendor: 'corpus-builder'

    helpers do
      def status_fail
        status 403
      end

      def action! action
        action = action.run params
        if action.valid?
          action.result
        else
          status_fail
          action.errors
        end
      end
    end
  end
end
