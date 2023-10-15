# frozen_string_literal: true

require "rails"

module RailsKeyRotator
  class Railtie < Rails::Railtie
    config.before_initialize do
      KeyRotator.rotated?
    end
  end
end
