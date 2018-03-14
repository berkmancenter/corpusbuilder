require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

require 'rspec/rails'
require 'webmock/rspec'

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include FactoryGirl::Syntax::Methods

  config.after(:each) do
    if Rails.env.test?
      FileUtils.rm_rf(Dir["#{Rails.root}/spec/support/uploads"])
    end
  end

  config.include(ActiveJob::TestHelper)

  config.before(:suite) { FactoryGirl.reload }

  config.include RSpec::Rails::RequestExampleGroup,
    type: :request,
    file_path: /spec\/api/

  config.include RSpec::Rails::RequestExampleGroup,
    type: :request,
    file_path: /spec\/api\/v1/
end

class ActiveJob::QueueAdapters::DelayedJobAdapter
  class EnqueuedJobs
    def clear
      Delayed::Job.where(failed_at:nil).map(&:destroy)
    end
  end

  class PerformedJobs
    def clear
      Delayed::Job.where.not(failed_at:nil).map(&:destroy)
    end
  end

  def enqueued_jobs
    EnqueuedJobs.new
  end

  def performed_jobs
    PerformedJobs.new
  end
end
