class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document)
    self.send "when_#{document.status}", document
  end

  protected

  def when_initial(document)
    Pipeline::Nidaba.create! document_id: document.id
    document.processing!
    reschedule
  end

  def when_processing(document)
    case document.pipeline.poll
    when "error"
      document.error!
    when "success"
      document.ready!
    else
      reschedule
    end
  end

  def when_error(document)
    # no-op
  end

  def when_ready(document)
    # no-op
  end

  private

  def reschedule(wait = 1.minute)
    ProcessDocumentJob.
      set(wait: wait).
      perform_later
  end
end
