require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module CorpusBuilder
  class Application < Rails::Application
    config.load_defaults 5.1
  end
end
