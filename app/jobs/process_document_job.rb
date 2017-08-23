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

  private

  def reschedule(wait = 1.minute)
    ProcessDocumentJob.
      set(wait: wait).
      perform_later
  end
end
