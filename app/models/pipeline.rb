class Pipeline < ApplicationRecord
  include Workflow

  workflow status: [ :initial, :processing, :error, :success ]

  belongs_to :document

  def forward!
    update_attribute :status, Pipeline.statuses[forward]

    case self.status
    when "success"
      document.ready!
    when "error"
      document.error!
    end

    status
  end

  def forward
    raise NotImplementedError
  end

  def start
    raise NotImplementedError
  end

  def cleanup!
    raise NotImplementedError
  end

  def result
    raise NotImplementedError
  end

  def assert_status(status)
    if self.status.to_s != status.to_s
      raise Pipeline::Error.new, "Expected pipeline with status #{status}"
    end
  end

  class Error < StandardError
  end
end
