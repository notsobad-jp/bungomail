Delayed::Worker.destroy_failed_jobs = false
Delayed::Worker.max_attempts = 1
Delayed::Worker.sleep_delay = 300

if Rails.env.development?
  Delayed::Worker.delay_jobs = ->(job) {
    job.queue == 'feed_email' || job.queue == 'web_push' # 開発環境ではfeedの予約配信 or WebPushのみ遅延実行
  }
end
