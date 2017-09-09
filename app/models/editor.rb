class Editor < ApplicationRecord
  validates :email, presence: true

  class Simple < Grape::Entity
    expose :id
    expose :email
  end
end
