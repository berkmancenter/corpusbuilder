class Grapheme < ApplicationRecord
  belongs_to :zone
  has_and_belongs_to_many :revisions

  enum status: [ :regular, :conflict ]

  serialize :area, Area::Serializer

  default_scope { order("(graphemes.area[0])[1] asc, (graphemes.area[0])[0] asc") }

  class Tree < Grape::Entity
    expose :area, with: Area::Tree
    expose :value
    expose :id
    expose :certainty
  end

  class Diff < Grape::Entity
    expose :area, with: Area::Tree
    expose :value
    expose :id
    expose :inclusion
    expose :zone_id
  end
end
