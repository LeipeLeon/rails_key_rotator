# frozen_string_literal: true

require "rails"

module RailsKeyRotator
  class Railtie < Rails::Railtie
    config.before_configuration do
      RailsKeyRotator.rotated?
    end
    rake_tasks do
      load "tasks/key_rotator.rake"
    end
  end
end
