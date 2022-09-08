require_relative "boot"

require 'csv'
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Proposals
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    config.time_zone = "Pacific Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # add Bootstrap 5 error classes to validated forms
    config.action_view.field_error_proc = Proc.new { |html_tag, instance|
      if html_tag.match? "<input"
        html_tag.gsub!(/class=\"/, "class=\"is-invalid\ ")
      end

      "<div class=\"field_with_errors has-validation\">#{html_tag}</div>".html_safe
    }

    EmailVerifier.config do |config|
      config.verifier_email = "realname@realdomain.com"
    end
  end
end
