namespace :db do
  namespace :structure do
    task :dump do
      IO.readlines("db/structure.sql").
        reject { |line| line[/^--/] }. # remove comments
        inject(OpenStruct.new(result: [ ], ommiting: false)) do |state, line|

        if state.ommiting
          if line[/^\);/]
            state.ommiting = false
          end
        else
          if line[/CREATE TABLE public.graphemes_revisions/]
            state.ommiting = true
          else
            state.result << line
          end
        end

        state
      end.result.tap do |filtered|
        IO.write "db/structure.sql", filtered.join('').gsub(/\n{3,}/, "\n\n")
      end
    end
  end
end
