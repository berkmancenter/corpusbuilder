class Grapheme < ApplicationRecord
  belongs_to :zone
  has_and_belongs_to_many :revisions

  serialize :area, Area::Serializer

  default_scope { order("(graphemes.area[0])[1] asc, (graphemes.area[0])[0] asc") }

  class Tree < Grape::Entity
    expose :area, with: Area::Tree
    expose :value
    expose :certainty
  end
end
