# frozen_string_literal: true

require_relative "rails_key_rotator/version"
require "tempfile"
require "active_support"
require "active_support/encrypted_configuration"

require "rails_key_rotator/railtie" if defined?(Rails)

module RailsKeyRotator
  class Error < StandardError; end

  class << self
    def rotated?
      return if ENV["RAILS_MASTER_KEY"].blank?

      if ENV.fetch("RAILS_MASTER_KEY_NEW", false)
        if can_read_credentials!
          ENV["RAILS_MASTER_KEY"] = ENV.fetch("RAILS_MASTER_KEY_NEW")
          say_loud "Using NEW key"
        else
          say_loud "Using OLD key"
        end
      end
    end

    def rotate
      puts "Starting process:"
      decrypted = read(credentials_path) # Decrypt current credentials
      backup_file(credentials_path)      # Backup credentials
      backup_file(key_path)              # Backup key
      write_key                          # Save new key
      write_credentials(decrypted)       # Save new credentials
      puts <<~PROCEDURE

        Finished! The next steps are:

        - Deploy `RAILS_MASTER_KEY_NEW=#{new_key}` to your infrastructure
        - Share the new key w/ your colleagues
        - Commit changes in #{credentials_path}
        - Update `RAILS_MASTER_KEY`and remove `RAILS_MASTER_KEY_NEW` from your infrastructure

      PROCEDURE
    end

    def credentials_path
      File.join(root, "config", "credentials", "#{env}.yml.enc")
    end

    def key_path
      File.join(root, "config", "credentials", "#{env}.key")
    end

    private

    def root
      defined?(Rails) ? Rails.root : Dir.pwd
    end

    def can_read_credentials!
      ActiveSupport::EncryptedConfiguration.new(
        config_path: credentials_path,
        env_key: "RAILS_MASTER_KEY_NEW",
        key_path: key_path,
        raise_if_missing_key: true
      ).read
    rescue ActiveSupport::MessageEncryptor::InvalidMessage
      false
    end

    def say(message)
      puts "-> #{message}"
    end

    def say_loud(message)
      warn "\e[41;37;1m\n\n\tKeyRotator(#{env}): #{message}\n\e[0m"
    end

    def env
      defined?(Rails) ? Rails.env : (ENV["RAILS_ENV"] || "test")
    end

    def date
      @date ||= Time.new.strftime("%Y-%m-%d-%H%M%S")
    end

    def new_key
      @new_key ||= ActiveSupport::EncryptedConfiguration.generate_key
    end

    def backup_file(original)
      raise "File does not exist: #{original}" unless File.exist?(original)
      say "Copy #{original} -> #{original}.bak-#{date}"
      FileUtils.mv(original, "#{original}.bak-#{date}")
    end

    def read(credentials_path) # the old configuration
      ActiveSupport::EncryptedConfiguration.new(
        config_path: credentials_path,
        key_path: key_path,
        env_key: "RAILS_MASTER_KEY",
        raise_if_missing_key: true
      ).read
    end

    def write_credentials(contents) # the new configuration
      ActiveSupport::EncryptedConfiguration.new(
        config_path: credentials_path,
        key_path: key_path,
        env_key: "",
        raise_if_missing_key: true
      ).write(contents)
    end

    def write_key
      say "Writing #{new_key} to #{key_path}"
      File.write(key_path, new_key)
    end
  end
end
