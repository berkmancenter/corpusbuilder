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
