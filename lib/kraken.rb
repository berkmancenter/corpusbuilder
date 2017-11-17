class Kraken
  def self.binarize(in_path, out_path)
    command = "kraken -i #{in_path} #{out_path} binarize"
    kraken_output = `#{command}`
    kraken_status = $?
    Rails.logger.info "Kraken output: #{kraken_output}"
    Rails.logger.info "Kraken status: #{kraken_status}"
    true
  end
end
