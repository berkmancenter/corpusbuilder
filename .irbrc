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

require 'rails/console/app'
extend Rails::ConsoleMethods

begin
  require "pry"
  Pry.start
  exit
rescue LoadError
  warn "=> Unable to load pry"
end

stdout_ar!
