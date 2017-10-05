module Documents
  class QueryAll < Action::Base
    attr_accessor :app, :status

    def execute
      scope = Document.where({})

      if app.present?
        scope = scope.where(app_id: app.id)
      end

      if status.present?
        scope = scope.where(status: status)
      end

      scope
    end
  end
end
