class Pipeline < ApplicationRecord
  include Workflow

  workflow status: [ :initial, :processing, :error, :success ]

  belongs_to :document

  def poll
    raise NotImplementedError
  end
end
