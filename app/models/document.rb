class Document < ApplicationRecord
  include Workflow

  workflow status: [ :initial, :processing, :error, :ready ]

  has_one :pipeline
end
