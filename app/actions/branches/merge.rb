module Branches
  class Merge < Action::Base
    attr_accessor :branch, :other_branch

    def execute
      branch.revision.grapheme_ids = other_branch.revision.grapheme_ids
    end
  end
end
