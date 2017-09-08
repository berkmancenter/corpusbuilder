class Document < ApplicationRecord
  include Workflow

  workflow status: [ :initial, :processing, :error, :ready ]

  has_one :pipeline
  has_many :revisions
  has_many :branches, through: :revisions
  has_many :surfaces
  has_many :images

  def master
    branches.where(name: 'master').first
  end

  def self.only_status
    select(:id, :status, :app_id)
  end

  def parse!(tei_xml)
    # todo: implement me
    ready!
  end

  class Status < Grape::Entity
    expose :status
  end

  class Tree < Grape::Entity
    expose :id
    expose :surfaces do |document, options|
      Surface::Tree.represent document.surfaces, options
    end
  end
end
