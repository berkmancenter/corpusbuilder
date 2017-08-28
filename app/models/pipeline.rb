class Pipeline < ApplicationRecord
  include Workflow

  workflow status: [ :initial, :processing, :error, :success ]

  belongs_to :document

  def poll
    raise NotImplementedError
  end

  def start
    raise NotImplementedError
  end

  def result
    raise NotImplementedError
  end

  class Error < StandardError
  end
end
