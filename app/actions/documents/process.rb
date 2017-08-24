module Documents
  class Process < Action::Base
    attr_accessor :document

    def execute
      self.send "when_#{@document.status}"
    end

    protected

    def when_initial
      Pipeline::Nidaba.create! document_id: @document.id
      @document.processing!
      reschedule
    end

    def when_processing
      case @document.pipeline.poll
      when "error"
        @document.error!
      when "success"
        # todo: implement the proper document graph creation
        image = Image.new name: "myimage.png"
        image.save(validate: false)
        head = Revision.create! document: @document
        surface = Surface.create! document: @document, image: image, number: 1, area: '((0,0),(0,0))'
        zone = Zone.create! surface: surface, area: '((0,0),(0,0))'
        g = Grapheme.create! zone: zone, area: '((0,0),(0,0))', value: 'y'
        head.graphemes << g
        Branch.create!(name: 'master', revision: head)
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
