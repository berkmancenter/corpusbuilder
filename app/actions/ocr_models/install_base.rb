module OcrModels
  class InstallBase < Action::Base
    attr_accessor :model

    def env_var
      raise StandardError, 'please override the #env_var method and returs a string name of the environment variable pointing at the backend data path'
    end

    def execute
      FileUtils.cp model.file.path, target_path
    end

    def target_path
      File.join data_path, model_file_name
    end

    def extension
      ''
    end

    def model_file_name
      name = "#{model.filename}"

      if !extension.strip.empty?
        name = "#{name.gsub(/#{extension}/, '')}#{extension}"
      end

      name
    end

    def data_path
      ENV[env_var].tap do |path|
        raise RuntimeError, "#{env_var} environment variable must be specified!" if path.nil?
      end
    end
  end
end

