require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

Dotenv::Railtie.load if !Rails.env.production?

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

    def load_console(app = self)
      super
      project_specific_irbrc = File.join(Rails.root, ".irbrc")
      puts "Loading project specific .irbrc ..."
      load(project_specific_irbrc) if File.exists?(project_specific_irbrc)
    end
  end
end
