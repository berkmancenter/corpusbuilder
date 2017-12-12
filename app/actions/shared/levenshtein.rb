module Shared
  class Levenshtein < Action::Base
    attr_accessor :first, :second

    # Thank you wikibooks :)
    # https://en.wikibooks.org/wiki/Algorithm_Implementation/Strings/Levenshtein_distance#Ruby
    def execute
      matrix = [(0..first.length).to_a]
      (1..second.length).each do |j|
        matrix << [j] + [0] * (first.length)
      end

      (1..second.length).each do |i|
        (1..first.length).each do |j|
          if first[j-1] == second[i-1]
            matrix[i][j] = matrix[i-1][j-1]
          else
            matrix[i][j] = [
              matrix[i-1][j],
              matrix[i][j-1],
              matrix[i-1][j-1],
            ].min + 1
          end
        end
      end
      return matrix.last.last
    end
  end
end
