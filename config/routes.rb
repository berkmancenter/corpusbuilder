module ActionDispatch
  module Journey
    class Routes
      def simulator
        @simulator ||= begin
          gtg = GTG::Builder.new(ast).transition_table unless ast.blank?
          GTG::Simulator.new(gtg)
        end
      end
    end
  end
end

Rails.application.routes.draw do
  # root controller: :home, action: :index

  get 'examples/viewer', to: 'home#example_viewer'

  mount API, at: '/'
end
