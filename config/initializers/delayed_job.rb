Delayed::Worker.max_attempts = 5
Delayed::Worker.max_run_time = 5.minutes # no current DJ jobs are long
Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.backend = :active_record 