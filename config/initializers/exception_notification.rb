require 'exception_notification/rails'

ExceptionNotification.configure do |config|
  config.ignore_if do |exception, options|
    Rails.env.test?
  end

  config.add_notifier :email, {
    :email_prefix         => "[ERROR] ",
    :sender_address       => %{"CorpusBuilder Instance" <instance@corpusbuild.er>},
    :exception_recipients => (ENV["CORPUS_BUILDER_EXCEPTION_RECIPIENTS"].try(:split) || []),
    :delivery_method      => :sendmail
  }
end
