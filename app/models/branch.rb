class Branch < ApplicationRecord
  belongs_to :revision
  belongs_to :editor

  enum status: [ :regular, :locked ]

  validates :editor_id, presence: true

  def working
    Revision.working.where(parent_id: self.revision_id).first
  end

  def conflict?
    working.conflict?
  end

  def graphemes
    revision.graphemes
  end

  class Simple < Grape::Entity
    root 'branches', 'branch'

    expose :name
    expose :revision_id
    expose :working_id do |branch, _|
      branch.working.try(:id)
    end
    expose :editor, with: Editor::Simple
    expose :editable do |branch, options|
      options[:editor_id].present? && options[:editor_id] == branch.editor_id
    end
  end
end
