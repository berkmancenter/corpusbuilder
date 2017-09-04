class Surface < ApplicationRecord
  belongs_to :document
  belongs_to :image

  has_many :zones

  serialize :area, Area::Serializer
end
