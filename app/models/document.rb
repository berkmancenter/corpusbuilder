class Document < ApplicationRecord
  enum status: [ :initial, :processing, :error, :ready ]
end
