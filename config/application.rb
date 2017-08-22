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

    config.autoload_paths += Dir["#{config.root}/app/actions"]
    config.autoload_paths += Dir["#{config.root}/lib"]

    config.active_job.queue_adapter = :que

    if Rails.env.development?
      config.web_console.whitelisted_ips = '172.19.0.1'
    end
  end
end
