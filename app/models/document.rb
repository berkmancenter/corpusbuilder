class Document < ApplicationRecord
  enum status: [ :initial, :processing, :error, :ready ]

  def processing!
    update_status :processing
  end

  private

  def update_status(status)
    update_attribute :status, Document.statuses[status]
  end
end
