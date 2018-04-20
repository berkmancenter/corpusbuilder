module Documents::Export
  class ExportLineBoxesTesseract < Action::Base
    attr_accessor :zone, :document

    def execute
      raise NotImplementedError
    end
  end
end


