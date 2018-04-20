IRB.conf[:USE_READLINE] = true
IRB.conf[:AUTO_INDENT]  = false

require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{Rails.root}/tmp/.irb-save-history"

def mute_ar!
  ActiveRecord::Base.logger = nil
  puts "Muted ActiveRecord logging"
end

def stdout_ar!
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  puts "Logging ActiveRecord to STDOUT"
end

begin
  require 'wirble'
  Wirble.init
  Wirble.colorize
rescue
  put "Wirble not available"
end

begin
  require 'hirb/import_object'
  Hirb.enable
  extend Hirb::Console
rescue
  put "Hirb gem not available"
end

stdout_ar!
