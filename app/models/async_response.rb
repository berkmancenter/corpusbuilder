class AsyncResponse < ApplicationRecord
  enum status: [ :initial, :success, :error ]

  class Simple < Grape::Entity
    expose :id
  end
end
