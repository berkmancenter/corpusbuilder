module V1Base
  extend ActiveSupport::Concern

  UUID_PATTERN = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/

  included do
    format :json
    prefix :api
    version 'v1', using: :header, vendor: 'corpus-builder'

    rescue_from Grape::Exceptions::ValidationErrors do |e|
      reply = e.errors.inject({}) do |sum, err|
        err.first.each do |field|
          sum[field] ||= []
          sum[field] += err.last.map(&:to_s)
        end
        sum
      end

      error!(reply, 400)
    end

    rescue_from :all do |e|
      if !e.is_a? Grape::Exceptions::Base
        Rails.logger.error "Error inside action: #{e.message}\nBacktrace:\n#{e.backtrace.join('\n')}"
        error!("Oops! Something went wrong", 500)
      else
        error!(e.message, e.status)
      end
    end

    helpers do
      def status_fail
        status 400
      end

      def uuid_pattern
        UUID_PATTERN
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

      def require_editor!
        @editor_id = headers['X-Editor-Id']

        if @editor_id.nil?
          error!('Missing X-Editor-Id header', 403)
        end
      end

      def action! action, additional_params = nil
        action = action.run(additional_params || params)
        if action.errors.empty?
          action.result
        else
          status_fail
          action.errors
        end
      rescue Exception => e
        Rails.logger.error "Error inside action: #{e.message}\nBacktrace:\n#{e.backtrace.join('\n')}"
        error!('Oops! Something went wrong', 500)
      end
    end
  end

  class_methods do
    def uuid_pattern
      UUID_PATTERN
    end
  end
end
