class Branch < ApplicationRecord
  belongs_to :revision
  belongs_to :editor

  validates :editor_id, presence: true

  has_many :graphemes, through: :revision

  def working
    Revision.working.where(parent_id: self.revision_id).first
  end

  class Simple < Grape::Entity
    root 'branches', 'branch'

    expose :name
    expose :revision_id
    expose :editor, with: Editor::Simple
  end
end
