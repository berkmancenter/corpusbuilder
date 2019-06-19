require_relative 'boot'

require 'rails/all'
require 'tabulo'
require "unicode/name"

Bundler.require(*Rails.groups)

Dotenv::Railtie.load if defined?(Dotenv) && !Rails.env.production?

module CorpusBuilder
  class Application < Rails::Application
    config.load_defaults 5.1

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    # config.middleware.use Rack::Deflater

    config.generators do |g|
      g.orm :active_record, primary_key_type: :uuid
    end

    config.autoload_paths += Dir["#{config.root}/app/actions"]
    config.autoload_paths += Dir["#{config.root}/lib"]
    config.autoload_paths += Dir["#{config.root}/lib/trestle/form/fields/"]

    config.active_job.queue_adapter = :delayed_job
    config.active_record.schema_format = :sql

    if Rails.env.development?
      config.web_console.whitelisted_ips = '194.28.12.52'
    end

    def load_console(app = self)
      super
      project_specific_irbrc = File.join(Rails.root, ".irbrc")
      puts "Loading project specific .irbrc ..."
      load(project_specific_irbrc) if File.exists?(project_specific_irbrc)
    end
  end
end
