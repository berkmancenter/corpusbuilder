require_relative 'boot'

require 'rails/all'
require 'tabulo'
require "unicode/name"

Bundler.require(*Rails.groups)

Dir["#{Rails.root.to_s}/app/actions/**/*.rb"].each { |f| require f }

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
    config.autoload_paths += Dir["#{config.root}/app/actions/accuracy_line_measurements"]
    config.autoload_paths += Dir["#{config.root}/app/actions/accuracy_measurements"]
    config.autoload_paths += Dir["#{config.root}/app/actions/annotations"]
    config.autoload_paths += Dir["#{config.root}/app/actions/branches"]
    config.autoload_paths += Dir["#{config.root}/app/actions/documents"]
    config.autoload_paths += Dir["#{config.root}/app/actions/editors"]
    config.autoload_paths += Dir["#{config.root}/app/actions/files"]
    config.autoload_paths += Dir["#{config.root}/app/actions/graphemes"]
    config.autoload_paths += Dir["#{config.root}/app/actions/images"]
    config.autoload_paths += Dir["#{config.root}/app/actions/ocr_models"]
    config.autoload_paths += Dir["#{config.root}/app/actions/pipelines"]
    config.autoload_paths += Dir["#{config.root}/app/actions/revisions"]
    config.autoload_paths += Dir["#{config.root}/app/actions/shared"]
    config.autoload_paths += Dir["#{config.root}/app/actions/zones"]
    config.autoload_paths += Dir["#{config.root}/lib/trestle/form/fields/"]

    config.eager_load_paths += Dir["#{config.root}/app/actions"]
    config.eager_load_paths += Dir["#{config.root}/lib"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/accuracy_line_measurements"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/accuracy_measurements"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/annotations"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/branches"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/documents"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/editors"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/files"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/graphemes"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/images"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/ocr_models"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/pipelines"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/revisions"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/shared"]
    config.eager_load_paths += Dir["#{config.root}/app/actions/zones"]
    config.eager_load_paths += Dir["#{config.root}/lib/trestle/form/fields/"]

    config.active_job.queue_adapter = :delayed_job
    config.active_record.schema_format = :sql
    ActiveRecord::Base.logger = Logger.new(File.join(Rails.root, 'log', 'activerecord.log'))

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
