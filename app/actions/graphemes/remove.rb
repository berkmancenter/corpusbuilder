module Graphemes
  class Remove < Action::Base
    attr_accessor :revision, :grapheme_id

    def execute
      revision.grapheme_ids -= [ @grapheme_id ]
    end
  end
end
