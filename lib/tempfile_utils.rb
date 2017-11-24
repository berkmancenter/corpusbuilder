require 'tmpdir'
require 'securerandom'

class TempfileUtils
  def self.next_path(part)
    File.join(Dir.tmpdir, "#{part}-#{SecureRandom.uuid}")
  end
end
