module Documents
  class Process < Action::Base
    attr_accessor :document

    def execute
      self.send "when_#{document.status}"
    end

    protected

    def when_initial
      Pipelines::Create.run! document: document
      document.processing!
      reschedule(0.1.second)
    end

    def when_processing
      case document.pipeline.forward!
      when "error"
        document.pipeline.cleanup!
      when "success"
        document.pipeline.result.each do |result|
          Documents::Compile.run! image_ocr_result: result.values.first,
            document: document, image_id: result.keys.first
        end
        document.ready!
        document.pipeline.cleanup!
      else
        reschedule(0.1.second)
      end
    rescue
      document.error!
      Rails.logger.error $!.message
      raise $!
    end

    def when_error
      # no-op
    end

    def when_ready
      # no-op
    end

    private

    def reschedule(wait = 1.minute)
      ProcessDocumentJob.
        set(wait: wait).
        perform_later(@document)
    end
  end
end
