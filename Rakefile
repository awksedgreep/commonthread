require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

# Default task
task :default => :test

# Test task
Rake::TestTask.new(:test) do |t|
    puts "Loading commonthread environment"
    puts "Note: Test debug log sent to /var/tmp/commonthread-test.log"
    t.libs << "lib"
    t.libs << "test"
    t.test_files = FileList['test/**/test*.rb']
    t.warning = false
end
