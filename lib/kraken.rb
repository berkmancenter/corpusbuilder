class Kraken
  def self.binarize(in_path, out_path)
    command = "kraken -i #{in_path} #{out_path} binarize"
    kraken_output = `#{command}`
    kraken_status = $?

    Rails.logger.info "> #{command}"
    Rails.logger.info kraken_output
    Rails.logger.info "(returned status): #{kraken_status}"

    if kraken_status != 0
      raise StandardError, "Kraken failed to binarize the image:\n\n> #{command}\n#{kraken_output}"
    end

    true
  end
end
