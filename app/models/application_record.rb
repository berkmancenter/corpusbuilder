class ApplicationRecord < ActiveRecord::Base
  include Memoizable

  after_save :clear_memoized

  self.abstract_class = true

  def base_url
    options = Rails.application.routes.default_url_options

    "#{options[:host]}:#{options[:port]}"
  end
end
