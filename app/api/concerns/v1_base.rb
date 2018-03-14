require 'term/ansicolor'
include Term::ANSIColor

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
      ExceptionHandler.process(e, env)

      if !e.is_a? Grape::Exceptions::Base
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

      def infer_editor!
        @editor_id = headers['X-Editor-Id']
      end

      def require_editor!
        infer_editor!

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
      rescue => e
        ExceptionHandler.process(e, env)
        error!("Oops! Something went wrong", 500)
      end

      def async! action, additional_params
        require_editor!

        resp = AsyncResponse.create! editor_id: @editor_id

        ProcessAsyncResponse.
          perform_later resp, action.name, (additional_params || params)

        status 202
        present resp, with: AsyncResponse::Simple
      end

      def infer_revision!(options = {})
        @revision_options = {}
        if uuid_pattern.match?(params[:revision])
          if @document.revisions.where(id: params[:revision]).empty?
            error!('Revision doesn\'t exist', 422)
          end

          @revision_options[:revision_id] = params[:revision]

          if options.fetch(:fetch, false)
            @revision = Revision.find(@revision_options[:revision_id])
            @branch = nil
          end
        else
          if @document.branches.where(name: params[:revision]).empty?
            error!('Branch doesn\'t exist', 422)
          end

          @revision_options[:branch_name] = params[:revision]

          if options.fetch(:fetch, false)
            error!('Expected document when fetching required branch', 500) if @document.nil?

            @revision = nil
            @branch = @document.branches.where(name: params[:revision]).first
          end
        end
      end

      def revision_from_params(params_name = :revision, options = { required: true })
        if uuid_pattern.match?(params[params_name])
          revision = @document.revisions.where(id: params[params_name]).first

          if !revision.present? && options[:required]
            error!('Revision doesn\'t exist', 422)
          else
            return revision
          end
        else
          branch = @document.branches.where(name: params[params_name]).first

          if !branch.present? && options[:required]
            error!("Branch doesn't exist", 422)
          end

          return branch.try(:revision)
        end
      end

      def fetch_and_authorize_document!
        authorize!

        @document = Document.find(params[:id])

        if @current_app.id != @document.app_id
          error!('You don\'t own the document', 403)
        end
      end
    end
  end

  class_methods do
    def uuid_pattern
      UUID_PATTERN
    end
  end
end
