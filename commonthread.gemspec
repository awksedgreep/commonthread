require 'rake'

# package target
PKG_VERSION = '0.1.55'
PKG_FILES = Rake::FileList[
    'Rakefile',
    'README.md',
    'bin/*',
    'lib/**/*.rb',
    'generators/*.rhtml',
    'framework/*',
    'test/**/test*.rb',
    'examples/**/*']

Gem::Specification.new do |s|
    s.platform = 'java'
    s.summary = "A Common Thread framework in the spirit of Rails."
    s.name = 'commonthread'
    s.license = 'BSD-Source-Code'
    s.version = PKG_VERSION
    s.require_path = 'lib'
    s.files = PKG_FILES.to_a
    s.bindir = "bin"
    s.executables = ['commonthread']
    s.description = "CommonThread facilitates the creation of producer consumer threads in an facilitative environment with built in queue management, intelligent startup/shutdown, and rails like simplicity.  It should lower the barrier to entry for writing complex threaded data processing applications and middleware."
    s.author = 'Mark Cotner'
    s.email = 'mark.cotner@gmail.com'
    s.homepage = 'http://www.github.com/awksedgreep/commonthread'
end
