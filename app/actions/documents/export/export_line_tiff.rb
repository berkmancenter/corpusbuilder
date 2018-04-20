module Documents::Export
  class ExportLineTiff < Action::Base
    attr_accessor :zone, :document

    def execute
      raise NotImplementedError
    end
  end
end

