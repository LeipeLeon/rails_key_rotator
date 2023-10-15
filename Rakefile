# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

task default: %i[spec standard]

desc "Show RailsKeyRotator version"
task :version do
  puts RailsKeyRotator::VERSION
end

Dir.glob("lib/tasks/*.rake").each { |r| import r }
