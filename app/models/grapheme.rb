class Grapheme < ApplicationRecord
  belongs_to :zone
  has_and_belongs_to_many :revisions

  serialize :area, Area::Serializer

  class Tree < Grape::Entity
    expose :area, with: Area::Tree
    expose :value
    expose :certainty
  end
end
