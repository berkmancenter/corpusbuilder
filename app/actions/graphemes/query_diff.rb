module Graphemes
  class QueryDiff < Action::Base
    attr_accessor :revision_left, :revision_right

    validates :revision_right, presence: true

    def execute
      side_query = -> (side) {
        rev1, rev2 = side == 'left' ? [ revision_left, revision_right ] : [ revision_right, revision_left ]

        Grapheme.where(id: rev1.graphemes).
                where.not(id: rev2.graphemes).
                select("graphemes.*, '#{side}' :: varchar as inclusion").
                reorder(nil)
      }

      if revision_left.present?
        side_query.call('left').
          union_all(
            side_query.call('right')
          )
      else
        revision_right.
          graphemes.
          select("distinct on (id) graphemes.*, 'right' :: varchar as inclusion").
          reorder(nil)
      end
    end
  end
end
