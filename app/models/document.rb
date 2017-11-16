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

  class Status < Grape::Entity
    expose :status
  end

  class Simple < Grape::Entity
    expose :id
    expose :title
    expose :author
    expose :date
  end

  class Tree < Grape::Entity
    expose :id
    expose :global do |document|
      {
        id: document.id,
        surfaces_count: document.surfaces.count,
        tallest_surface: (
          document.
            surfaces.
            select(%Q{
              ((surfaces.area[0])[1]) - ((surfaces.area[1])[1]) as height,
              ((surfaces.area[0])[0]) - ((surfaces.area[1])[0]) as width
            }).
            reorder(nil).
            order("height desc").
            limit(1).
            first.
            attributes.
            slice("height", "width")
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
