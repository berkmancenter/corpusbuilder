module Shared
  class NeedlemanWunsch < Action::Base
    attr_accessor :from, :to, :gap_penalty, :score_fn

    def execute
      # 1. prepare the score and transition matrices:
      score_matrix = (1..to.count + 1).inject([]) { |all, row| all << [0] * (from.count + 1); all }
      transition_matrix = (1..to.count + 1).inject([]) { |all, row| all << [nil] * (from.count + 1); all }

      score_matrix[0][0] = 0
      transition_matrix[0][0] = :done

      for column in 1..from.count
        score_matrix[0][column] = column * gap(from)
        transition_matrix[0][column] = :left
      end

      for row in 1..to.count
        score_matrix[row][0] = row * gap(to)
        transition_matrix[row][0] = :up
      end


      # 2. compute matrices values preparing for path inference:
      for row in 1..to.count
        for column in 1..from.count
          score = score_fn.call(from[ column - 1 ], to[ row - 1 ])

          values = [
            [ :diag, score_matrix[ row - 1  ][ column - 1 ] + score    ],
            [ :up,   score_matrix[ row - 1 ][ column     ] + gap(from) ],
            [ :left, score_matrix[ row     ][ column - 1 ] + gap(to)   ]
          ]

          choice = values.max_by { |value| value.last }

          score_matrix[ row ][ column ] = choice.last
          transition_matrix[ row ][ column ] = choice.first
        end
      end

      # 3. walk the path filling the alignment arrays:
      from_alignment = [ ]
      to_alignment = [ ]

      row = to.count
      column = from.count

      while row > 0 || column > 0
        direction = transition_matrix[ row ][ column ]

        case direction
        when :diag
          from_alignment.push from[ column - 1 ]
          to_alignment.push to[ row - 1 ]

          row -= 1
          column -= 1
        when :left
          from_alignment.push from[ column - 1 ]
          to_alignment.push nil

          column -= 1
        when :up
          from_alignment.push nil
          to_alignment.push to[ row - 1 ]

          row -= 1
        end
      end

      [
        from_alignment.reverse,
        to_alignment.reverse
      ]
    end

    def gap(a)
      if gap_penalty.is_a? Proc
        gap_penalty.call(a)
      else
        gap_penalty
      end
    end
  end
end
