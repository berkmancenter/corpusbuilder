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
      reschedule
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
        Rails.logger.info "Processing document #{document.id} done successfully"
      else
        reschedule
      end
    rescue
      Rails.logger.error $!.message
      document.error!
      raise $!
    end

    def when_error
      # no-op
    end

    def when_ready
      # no-op
    end

    private

    def reschedule
      ProcessDocumentJob.
        perform_later(@document)
    end
  end
end
