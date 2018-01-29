class Revision < ApplicationRecord
  include Workflow

  belongs_to :parent, class_name: 'Revision', required: false
  belongs_to :document

  workflow status: [ :regular, :working, :conflict ]

  has_many :branches, dependent: :destroy
  has_and_belongs_to_many :graphemes, dependent: :destroy
  has_and_belongs_to_many :annotations, dependent: :destroy

  scope :working, -> {
    where(status: [
      Revision.statuses[:working],
      Revision.statuses[:conflict]
    ])
  }

  def self.graphemes_revisions_partition_table_name(id)
    "graphemes_revisions_#{id.gsub(/-/, '_')}"
  end

  def graphemes_revisions_partition_table_name
    self.class.graphemes_revisions_partition_table_name(id)
  end
end
