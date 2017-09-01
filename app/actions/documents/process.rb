module Documents
  class Process < Action::Base
    attr_accessor :document

    def execute
      self.send "when_#{@document.status}"
    end

    protected

    def when_initial
      Pipelines::Create.run! document: @document
      @document.processing!
      reschedule
    end

    def when_processing
      case @document.pipeline.poll
      when "error"
        @document.error!
      when "success"
        @document.pipeline.result.each do |result|
          Documents::Compile.run! image_ocr_result: result
        end
        @document.ready!
      else
        reschedule
      end
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
