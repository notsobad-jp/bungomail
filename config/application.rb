require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BungoMail
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # 表示時のタイムゾーンをJSTに設定
    config.time_zone = 'Tokyo'

    # DB保存時のタイムゾーンをJSTに設定
    config.active_record.default_timezone = :local

    # ActiveJob設定
    config.active_job.queue_adapter = :delayed_job

    # i18n設定
    I18n.enforce_available_locales = false
    config.i18n.default_locale = :ja
    config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}').to_s]

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.autoload_paths += Dir["#{config.root}/lib/**/"]

    # Don't generate system test files.
    config.generators.system_tests = nil
  end
end
