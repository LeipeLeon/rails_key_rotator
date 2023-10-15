namespace :key_rotator do
  require "rails_key_rotator"
  require "fileutils"

  desc "Start rotation"
  task rotate: [
    # environment
  ] do
    RailsKeyRotator.rotate
  end
end
