module Pipelines
  class Create < Action::Base
    attr_accessor :document

    def execute
      pipeline.start
    end

    private

    def pipeline
      @_pipeline ||= Pipeline::Local.create! document: @document,
        status: "initial"
    end
  end
end
