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
    expose :graphemes do |surface, options|
      _graphemes = if options.key? :revision_id
        surface.graphemes.joins(:revisions).where(revisions: { id: options[:revision_id] })
      elsif options.key? :branch_name
        surface.graphemes.joins(revisions: :branches).where(branches: { name: options[:branch_name] })
      else
        surface.graphemes
      end
      Grapheme::Tree.represent _graphemes, options
    end
  end
end
