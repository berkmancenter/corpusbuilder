class Revision < ApplicationRecord
  include Workflow

  belongs_to :parent, class_name: 'Revision', required: false
  belongs_to :document

  workflow status: [ :regular, :working, :conflict ]

  has_many :branches, dependent: :destroy
  has_and_belongs_to_many :graphemes, dependent: :destroy

  scope :working, -> {
    where(status: [
      Revision.statuses[:working],
      Revision.statuses[:conflict]
    ])
  }
end
