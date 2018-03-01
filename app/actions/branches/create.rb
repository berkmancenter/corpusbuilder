module Branches
  class Create < Action::Base
    attr_accessor :document_id, :parent_revision_id, :editor_id, :name

    validates :document_id, presence: true
    validates :editor_id, presence: true
    validates :name, presence: true
    validate :unique_name

    def execute
      branch = Branch.create! revision_id: next_revision.id,
        name: @name,
        editor_id: @editor_id

      next_working

      branch
    end

    private

    def next_working
      @_next_working ||= Revisions::Create.run!(document_id: document_id,
                             parent_id: next_revision.id,
                             source: revision,
                             status: Revision.statuses[:working]).result
    end

    def next_revision
      @_next_revision ||= Revisions::Create.run!(document_id: document_id,
                                                 source: revision,
                                                 parent_id: revision.try(:id)).result
    end

    def revision
      if parent_revision_id.present?
        Revision.find parent_revision_id
      else
        nil
      end
    end

    def unique_name
      if revision.present? && revision.document.branches.where(name: name).present?
        errors.add(:name, 'must be unique within the document versions tree')
      end
    end
  end
end
