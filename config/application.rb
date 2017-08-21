require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

Dotenv::Railtie.load

module CorpusBuilder
  class Application < Rails::Application
    config.load_defaults 5.1
    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end
   # config.paths.add File.join('app', 'actions', 'editors'), glob: File.join('**', '*.rb')
   # config.autoload_paths += Dir[Rails.root.join('app', 'actions', 'editors', '*')]
   # [ 'api' ].each do |path|
   #   config.paths.add File.join('app', path), glob: File.join('**', '*.rb')
   #   config.autoload_paths += Dir[Rails.root.join('app', path, '*')]
   # end
    config.autoload_paths += Dir["#{config.root}/app/actions"]
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.web_console.whitelisted_ips = '172.19.0.1'
  end
end
