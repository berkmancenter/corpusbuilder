module Annotations
  class QueryAll < Action::Base
    attr_accessor :surface_number, :revision

    def execute
      revision.annotations.
        joins(:editor).
        where(surface_number: surface_number).
        select("annotations.*, editors.email as editor_email").
        uniq
    end
  end
end
