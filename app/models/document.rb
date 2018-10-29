class Document < ApplicationRecord
  include Workflow

  workflow status: [ :initial, :processing, :error, :ready ]

  has_one :pipeline, dependent: :destroy
  has_many :revisions, dependent: :destroy
  has_many :branches, through: :revisions
  has_many :surfaces, dependent: :destroy
  has_many :images
  belongs_to :app

  def master
    branches.where(name: 'master').first
  end

  def ocr_models
    OcrModel.where(id: ocr_model_ids)
  end

  class Status < Grape::Entity
    expose :status
  end

  class Simple < Grape::Entity
    expose :id
    expose :title
    expose :author
    expose :date
    expose :images_sample do |document|
      document.surfaces.joins(:image).take(10).map do |surface|
        {
          url: surface.image.processed_image_url
        }
      end
    end
  end

  class Tree < Grape::Entity
    expose :id
    expose :global do |document, options|
      tallest = document.
            surfaces.
            select(%Q{
              ((surfaces.area[0])[1]) - ((surfaces.area[1])[1]) as height,
              ((surfaces.area[0])[0]) - ((surfaces.area[1])[0]) as width
            }).
            reorder(nil).
            order("height desc").
            limit(1).
            first

      # todo: refactor the following:
      count_conflicts = if options.key? :branch_name
        branch = Branch.joins(:revision).where(
          revisions: { document_id: document.id },
          name: options[:branch_name]
        ).first
        result = Grapheme.connection.execute <<-SQL
          select count(graphemes.id)
          from #{branch.working.graphemes_revisions_partition_table_name}
          inner join graphemes on graphemes.id = grapheme_id
          where status = #{Grapheme.statuses[:conflict]}
        SQL
        result.first["count"]
      else
        revision = Revision.find(options[:revision_id])

        if revision.working? || revision.conflict?
          branch = Branch.joins(:revision).where(
            revisions: { id: revision.parent_id }
          ).first
          result = Grapheme.connection.execute <<-SQL
            select count(graphemes.id)
            from #{branch.working.graphemes_revisions_partition_table_name}
            inner join graphemes on graphemes.id = grapheme_id
            where status = #{Grapheme.statuses[:conflict]}
          SQL
          result.first["count"]
        end
      end

      {
        id: document.id,
        surfaces_count: document.surfaces.count,
        count_conflicts: count_conflicts.nil? ? nil : count_conflicts,
        tallest_surface: (
          tallest.try(:attributes).
            try(:slice, "height", "width")
        )
      }
    end
    expose :surfaces do |document, options|
      _surfaces = if options.key? :surface_number
        document.surfaces.where(number: options[:surface_number])
      else
        document.surfaces
      end
      Surface::Tree.represent _surfaces, options
    end
  end
end
