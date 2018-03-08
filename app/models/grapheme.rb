class Grapheme < ApplicationRecord
  belongs_to :zone

  enum status: [ :regular, :conflict ]

  serialize :area, Area::Serializer

  default_scope { order(:position_weight) }

  def special?
    [ 0x200f, 0x200e, 0x202c ].include? value.codepoints.first
  end

  class Tree < Grape::Entity
    expose :area, with: Area::Tree
    expose :value
    expose :position_weight
    expose :status do |grapheme|
      grapheme.status
    end
    expose :id
    expose :zone_id
    expose :zone_position_weight
    expose :zone_direction
    expose :certainty
  end

  class Diff < Grape::Entity
    expose :area, with: Area::Tree
    expose :value
    expose :id
    expose :inclusion
    expose :surface_number
    expose :parent_ids
    expose :zone_id
  end
end
