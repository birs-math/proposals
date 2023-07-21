require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.cache_classes = true

  config.eager_load = false

  config.consider_all_requests_local = true

  config.active_job.queue_adapter = :sucker_punch

  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  config.active_support.deprecation = :log

  config.active_support.disallowed_deprecation = :raise

  config.active_support.disallowed_deprecation_warnings = []

  config.active_record.migration_error = :page_load

  config.active_record.verbose_query_logs = true

  config.assets.debug = true

  config.assets.quiet = true

  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.action_mailer.default_url_options = { host: ENV['APPLICATION_HOST'] }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = { address: ENV['MAILHOG_HOST'], port: 1025 }
  config.action_mailer.perform_deliveries = true

  Rails.application.routes.default_url_options[:host] = ENV['APPLICATION_HOST']

  config.hosts << ENV['APPLICATION_HOST']
end
