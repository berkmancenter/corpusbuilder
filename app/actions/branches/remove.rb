module Branches
  class Remove < Action::Base
    attr_accessor :branch, :editor_id

    validate :editor_owns_branch

    def execute
      branch.delete
    end

    def editor_owns_branch
      if branch.editor_id != editor_id
        errors.add(:editor_id, "must own the branch")
      end
    end
  end
end
