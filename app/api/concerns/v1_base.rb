module V1Base
  extend ActiveSupport::Concern

  included do
    format :json
    prefix :api
    version 'v1', using: :header, vendor: 'corpus-builder'

    before do
      @current_app = App.find headers['X-App-Id']
      authorize!
    end

    helpers do
      def status_fail
        status 400
      end

      def authorize!
        # todo: implement the check against app's secret
      end

      def with_authorized_document(document, &block)
        if document.app_id == @current_app.id
          block.call
        else
          status 403
        end
      end

      def action! action, additional_params
        action = action.run params.merge(additional_params)
        if action.valid?
          action.result
        else
          status_fail
          action.errors
        end
      end
    end
  end

  class_methods do
    def uuid_pattern
      /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/
    end
  end
end
