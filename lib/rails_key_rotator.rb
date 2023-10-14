# frozen_string_literal: true

require_relative "rails_key_rotator/version"
require "tempfile"
require "active_support"
require "active_support/encrypted_configuration"

require "rails_key_rotator/railtie" if defined?(Rails)

module RailsKeyRotator
  class Error < StandardError; end
  # Your code goes here...
  class << self
    def call
      return if ENV["RAILS_MASTER_KEY"].blank?

      if ENV.fetch("RAILS_MASTER_KEY_NEW", false)
        if can_read_credentials!
          ENV["RAILS_MASTER_KEY"] = ENV.fetch("RAILS_MASTER_KEY_NEW")
          say "NEW key"
        else
          say "OLD key"
        end
      end
    end

    def credentials_path
      File.join(root, "config", "credentials", "#{env}.yml.enc")
    end

    private

    def root
      defined?(Rails) ? Rails.root : Dir.pwd
    end

    def can_read_credentials!
      ActiveSupport::EncryptedConfiguration.new(
        config_path: credentials_path,
        env_key: "RAILS_MASTER_KEY_NEW",
        key_path: "",
        raise_if_missing_key: true
      ).read
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      false
    end

    def say(message)
      warn "\e[41;37;1m\n\n\tKeyRotator: Using #{message} for #{env} env\n\e[0m"
    end

    def env
      defined?(Rails) ? Rails.env : (ENV["RAILS_ENV"] || "test")
    end
  end
end
