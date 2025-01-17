Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Check if we use Docker to allow docker ip through web-console
  if File.file?('/.dockerenv') == true
    host_ip = `/sbin/ip route|awk '/default/ { print $3 }'`.strip
    config.web_console.whitelisted_ips = config.web_console.whitelisted_ips || []
    config.web_console.whitelisted_ips << host_ip
  end

  config.action_mailer.preview_path = "#{Rails.root}/spec/mailers/previews"

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
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

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :authentication => ENV["SMTP_AUTHENTICATION"].blank? ? nil : ENV["SMTP_AUTHENTICATION"].to_sym,
    :address => ENV["SMTP_ADDRESS"].blank? ? nil : ENV["SMTP_ADDRESS"],
    :port => ENV["SMTP_PORT"].blank? ? nil : ENV["SMTP_PORT"],
    :domain => ENV["SMTP_DOMAIN"].blank? ? nil : ENV["SMTP_DOMAIN"],
    :user_name => ENV["SMTP_USERNAME"].blank? ? nil : ENV["SMTP_USERNAME"],
    :password => ENV["SMTP_PASSWORD"].blank? ? nil : ENV["SMTP_PASSWORD"],
    :enable_starttls_auto => ENV["SMTP_ENABLE_STARTTLS_AUTO"].blank? ? nil : ENV["SMTP_ENABLE_STARTTLS_AUTO"],
    :openssl_verify_mode => ENV["SMTP_OPENSSL_VERIFY_MODE"].blank? ? nil : ENV["SMTP_OPENSSL_VERIFY_MODE"],
    :tls => ENV["SMTP_TLS"].blank? ? nil : ENV["SMTP_TLS"]
  }

  # Set host so asset_path returns a full URL instead of a relative path.
  # Otherwise images in emails don't work.
  config.action_controller.asset_host = ENV['ASSET_HOST']
  config.action_mailer.asset_host = config.action_controller.asset_host

  # Store uploaded files on the local file system (see config/storage.yml for options).
  config.active_storage.service = :local

  config.action_mailer.raise_delivery_errors = ENV['MAIL_RAISE_DELIVERY_ERRORS_DEV'] == 'true'
  config.action_mailer.perform_deliveries = ENV['MAIL_PERFORM_DELIVERIES_DEV'] == 'true'

  config.action_mailer.perform_caching = false

  config.action_mailer.default_url_options = { host: "localhost:3000" }

  # Set host so asset_path returns a full URL instead of a relative path.
  # Otherwise images in emails don't work.
  config.action_controller.asset_host = 'http://localhost:3000'
  config.action_mailer.asset_host = config.action_controller.asset_host

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations.
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.

  # The default "EventedFileUpdateChecker" is not working when working on Windows.
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.file_watcher = ActiveSupport::FileUpdateChecker

  if ENV['PROPRIETARY_MODE'] == 'true'
    config.active_job.queue_adapter = :sidekiq
  end
end
