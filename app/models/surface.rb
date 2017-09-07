class Surface < ApplicationRecord
  belongs_to :document
  belongs_to :image

  has_many :zones
  has_many :graphemes, through: :zones

  serialize :area, Area::Serializer

  class Tree < Grape::Entity
    expose :number
    expose :area, with: Area::Tree
    expose :graphemes, with: Grapheme::Tree
  end
end
