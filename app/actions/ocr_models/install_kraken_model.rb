module OcrModels
  class InstallKrakenModel < InstallBase
    def env_var
      'KRAKEN_DATA_PREFIX'
    end
  end
end
