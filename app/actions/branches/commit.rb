module Branches
  class Commit < Action::Base
    attr_accessor :branch

    validates :branch, presence: true
    validate :working_exists

    def execute
      working.regular!
      new_regular = working

      new_working = Revisions::Create.run!(document_id: branch.revision.document_id,
        parent_id: working.id,
        status: Revision.statuses[:working]).result

      new_working.graphemes << new_regular.graphemes

      branch.update_attributes!(revision_id: new_regular.id)

      branch
    end

    private

    def working
      @_working ||= branch.working
    end

    def working_exists
      if !working.present?
        error.add(:base, "a branch needs to have a working revision")
      end
    end
  end
end
