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
      document.surfaces.reorder(nil).select(
        %Q{max((surfaces.area[0])[1]) as bottom_max,
           min((surfaces.area[1])[1]) as top_min,
           min((surfaces.area[1])[0]) as left_min,
           max((surfaces.area[0])[0]) as right_max,
           count(surfaces.*) as surfaces_count}
      ).first.
     attributes.slice("surfaces_count", "bottom_max", "top_min", "left_min", "right_max").
     merge(id: document.id)
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
