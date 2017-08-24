class Branch < ApplicationRecord
  belongs_to :revision

  has_many :graphemes, through: :revision
end
