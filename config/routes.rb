Rails.application.routes.draw do
  # root controller: :home, action: :index

  get 'examples/viewer', to: 'home#example_viewer'

  mount API, at: '/'
end
