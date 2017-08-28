class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document)
    Documents::Process.run! document: document
  end
end
