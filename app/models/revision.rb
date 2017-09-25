class Revision < ApplicationRecord
  include Workflow

  belongs_to :parent, class_name: 'Revision', required: false
  belongs_to :document

  workflow status: [ :regular, :working, :conflict ]

  has_many :branches
  has_and_belongs_to_many :graphemes

  scope :working, -> {
    where(status: [
      Revision.statuses[:working],
      Revision.statuses[:conflict]
    ])
  }
end
