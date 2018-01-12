class Grapheme < ApplicationRecord
  belongs_to :zone
  has_and_belongs_to_many :revisions

  enum status: [ :regular, :conflict ]

  serialize :area, Area::Serializer

  default_scope { order(:position_weight) }

  class Tree < Grape::Entity
    expose :area, with: Area::Tree
    expose :value
    expose :status do |grapheme|
      grapheme.status
    end
    expose :id
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
