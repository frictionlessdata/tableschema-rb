require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "open-uri"

RSpec::Core::RakeTask.new(:spec)

task default: :spec

task :update_profiles do
  open('https://specs.frictionlessdata.io/schemas/table-schema.json') do |remote_schema|
    File.open('./lib/profiles/table-schema.json', 'w') do |local_schema|
      local_schema << remote_schema.read
    end
  end
end
