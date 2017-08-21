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
    end
  end
end
