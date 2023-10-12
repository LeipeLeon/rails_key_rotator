# frozen_string_literal: true

require_relative "rails_key_rotator/version"
require "tempfile"
require "active_support"
require "active_support/encrypted_configuration"

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

    private

    def can_read_credentials!
      ActiveSupport::EncryptedConfiguration.new(
        config_path: credential_path,
        env_key: "RAILS_MASTER_KEY_NEW",
        key_path: "",
        raise_if_missing_key: true
      ).read
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      false
    end

    def credential_path
      Rails.root.join("config/credentials/#{env}.yml.enc")
    end

    def say(message)
      warn "\e[41;37;1m\n\n\tKeyRotator: Using #{message} for #{env} env\n\e[0m"
    end

    def env
      defined?(Rails) ? Rails.env : (ENV["RAILS_ENV"] || "test")
    end
  end
end
