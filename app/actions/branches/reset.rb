module Branches
  class Reset < Action::Base
    attr_accessor :branch

    def execute
      Revisions::PointAtSameGraphemes.run! source: branch.revision, target: branch.working
      branch.working.working!
      branch
    end
  end
end
