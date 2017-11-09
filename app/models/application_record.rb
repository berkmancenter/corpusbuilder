class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def base_url
    options = Rails.application.routes.default_url_options

    "#{options[:host]}:#{options[:port]}"
  end
end
