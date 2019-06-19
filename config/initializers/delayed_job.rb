Delayed::Worker.sleep_delay = 0.1
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 1.day
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = true
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
