module OcrModels
  class QueryAll < Action::Base
    attr_accessor :backend, :scripts, :languages

    def execute
      scope = base_scope

      if backend.present?
        scope = scope.where(backend: backend)
      end

      scope
    end

    def base_scope
      OcrModel.where({})
    end
  end
end
