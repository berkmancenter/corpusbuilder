class Editor < ApplicationRecord
  validates :email, presence: true

  class Simple < Grape::Entity
    expose :email
  end
end
