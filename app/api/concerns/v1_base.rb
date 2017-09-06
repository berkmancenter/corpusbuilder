module V1Base
  extend ActiveSupport::Concern

  included do
    format :json
    prefix :api
    version 'v1', using: :header, vendor: 'corpus-builder'

    helpers do
      def status_fail
        status 400
      end

      def authorize!
        app_id = headers['X-App-Id']
        if app_id.present?
          @current_app = App.where(id: app_id).first

          token = headers['X-Token']
          if token.present?
            if BCrypt::Password.new(token) == @current_app.secret
            else
              error!('Invalid X-Token header', 403)
            end
          else
            error!('Missing X-Token header', 403)
          end
        else
          error!('Missing X-App-ID header', 403)
        end
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
