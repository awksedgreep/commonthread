require 'rake'
require 'rake/testtask'
require 'rake/gempackagetask'
require 'rake/rdoctask'

# test target
Rake::TestTask.new do |test|
    test.libs  << "lib"
end

# package target
PKG_VERSION = '0.1.29'
PKG_FILES = FileList[
    'Rakefile',
    'README.rdoc',
    'bin/*',
    'lib/**/*.rb',
    'generators/*.rhtml',
    'framework/*',
    'test/**/test*.rb',
    'examples/**/*']

spec = Gem::Specification.new do |s|
    s.platform = Gem::Platform::RUBY
    s.summary = "A Common Thread framework in the spirit of Rails."
    s.name = 'commonthread'
    s.version = PKG_VERSION
    s.require_path = 'lib'
    s.files = PKG_FILES.to_a
    s.autorequire = 'commonthread_env'
    s.bindir = "bin"
    s.executables = ['commonthread', 'generate']
    s.default_executable = 'commonthread'
    s.has_rdoc = true
    s.extra_rdoc_files = ['README.rdoc']    
    s.rdoc_options << '--main' << 'README.rdoc' <<
                      '--title' << 'CommonThread Framework' <<
                      '--inline-source' << '--line-numbers'
    s.description = "CommonThread facilitates the creation of producer consumer threads in an facilitative environment with built in queue management, intelligent startup/shutdown, and rails like simplicity.  It should lower the barrier to entry for writing complex threaded data processing applications and middleware."
    s.author = 'Mark Cotner'
    s.email = 'mark.cotner@gmail.com'
    #s.rubyforge_project = 'commonthread'
    s.homepage = 'http://www.github.com/awksedgreep/commonthread'
end

Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
end

Rake::TestTask.new do |t|
    puts "Loading commonthread environment"
    puts "Note:  Test debug log sent to /var/tmp/commonthread-test.log"
    t.libs << "lib/commonthread"
    t.test_files = FileList['test/**/test*.rb']
    #t.verbose = true
    sleep 0.1 # to wait for any logconsumers to finish consuming the log
end
