require "bundler/gem_tasks"
require "rspec/core/rake_task"
require "open-uri"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

task :update_profiles do
  profiles = [
    {
      remote_schema: 'https://specs.frictionlessdata.io/schemas/table-schema.json',
      local_schema: './lib/profiles/table-schema.json'
    },
    {
      remote_schema: 'https://raw.githubusercontent.com/fge/sample-json-schemas/master/geojson/geojson.json',
      local_schema: './lib/profiles/geojson.json'
    }
  ]
  profiles.each do |profile|
    open(profile[:remote_schema]) do |remote_schema|
      File.open(profile[:local_schema], 'w') do |local_schema|
        local_schema << remote_schema.read
      end
    end
  end
end
