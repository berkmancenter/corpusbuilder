class Editor < ApplicationRecord
  validates :email, presence: true
end
