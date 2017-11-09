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
      surface.image.image_scan_url
    end
    expose :graphemes do |surface, options|
      _graphemes = if options.key? :revision_id
        surface.graphemes.joins(:revisions).where(revisions: { id: options[:revision_id] })
      elsif options.key? :branch_name
        branches_query = Branch.joins(:revision).where(revisions: { document_id: surface.document_id })
        working_query = Revision.working.where(
          parent_id: branches_query.where(name: options[:branch_name]).select(:revision_id)
        )
        surface.graphemes.joins(:revisions).where(revisions: { id: working_query })
      else
        surface.graphemes
      end

      if options.key? :area
        _graphemes = _graphemes.where("graphemes.area <@ ?", options[:area].to_s)
      end

      Grapheme::Tree.represent _graphemes, options
    end
  end
end
