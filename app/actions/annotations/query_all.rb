module Annotations
  class QueryAll < Action::Base
    attr_accessor :surface_number, :revision

    def execute
      revision.annotations.
        where(surface_number: surface_number).
        uniq
    end
  end
end
