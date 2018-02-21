Delayed::Worker.sleep_delay = 15
Delayed::Worker.max_attempts = 3
Delayed::Worker.max_run_time = 15.minutes
Delayed::Worker.default_queue_name = 'default'
Delayed::Worker.delay_jobs = !Rails.env.test?
Delayed::Worker.logger = Logger.new(File.join(Rails.root, 'log', 'delayed_job.log'))
