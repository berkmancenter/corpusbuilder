if Rails.env.test?
  CarrierWave.configure do |config|
    config.storage = :file
    config.enable_processing = false
    config.asset_host = ActionController::Base.asset_host
  end

  ImageScanUploader

  CarrierWave::Uploader::Base.descendants.each do |klass|
    next if klass.anonymous?
    klass.class_eval do
      def cache_dir
        "#{Rails.root}/spec/support/uploads/tmp"
      end

      def store_dir
        "#{Rails.root}/spec/support/uploads/#{model.class.to_s.underscore}"
      end
    end
  end
end
