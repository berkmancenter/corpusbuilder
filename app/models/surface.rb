class Surface < ApplicationRecord
  belongs_to :document
  belongs_to :image

  has_many :zones
  has_many :graphemes, through: :zones

  serialize :area, Area::Serializer

  default_scope { order("surfaces.number asc") }

  class Tree < Grape::Entity
    expose :number
    expose :area, with: Area::Tree
    expose :image_url do |surface, options|
      surface.image.processed_image_url
    end
    expose :graphemes do |surface, options|
      _graphemes = Graphemes::QueryPage.run!(
        surface: surface,
        revision_id: options[:revision_id],
        branch_name: options[:branch_name],
        area: options[:area]
      ).result

      Grapheme::Tree.represent _graphemes.uniq, options
    end
  end
end
