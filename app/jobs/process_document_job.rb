class ProcessDocumentJob < ApplicationJob
  queue_as :default

  def perform(document)
    # Do something later
  end
end
