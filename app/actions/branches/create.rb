module Branches
  class Create < Action::Base
    attr_accessor :parent_revision_id, :editor_id, :name

    validate :unique_name

    def execute
      Branch.create! revision_id: next_revision.id,
        name: @name,
        editor_id: @editor_id
    end

    private

    def next_revision
      @_next_revision ||= Revisions::Create.run!(document_id: revision.document_id,
                                                 parent_id: revision.id).result
    end

    def revision
      Revision.find @parent_revision_id
    end

    def unique_name
      if revision.document.branches.where(name: name).present?
        errors.add(:name, 'must be unique within the document versions tree')
      end
    end
  end
end
