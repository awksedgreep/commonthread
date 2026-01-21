# package target
PKG_VERSION = '0.1.57'

Gem::Specification.new do |s|
    s.platform = 'java'
    s.summary = "A Common Thread framework in the spirit of Rails."
    s.name = 'commonthread'
    s.license = 'BSD-Source-Code'
    s.version = PKG_VERSION
    s.require_paths = ['lib']
    s.files = Dir['Rakefile', 'README.md', 'bin/*', 'lib/**/*.rb', 'generators/*.rhtml', 'framework/*', 'test/**/test*.rb', 'examples/**/*']
    s.bindir = "bin"
    s.executables = ['commonthread']
    s.description = "CommonThread facilitates the creation of producer consumer threads in a facilitative environment with built in queue management, intelligent startup/shutdown, and rails like simplicity. It should lower the barrier to entry for writing complex threaded data processing applications and middleware."
    s.author = 'Mark Cotner'
    s.email = 'mark.cotner@gmail.com'
    s.homepage = 'https://github.com/awksedgreep/commonthread'
    
    s.required_ruby_version = '>= 2.5.0'
    s.required_rubygems_version = '>= 3.0.0'
    s.metadata = {
      'homepage_uri' => 'https://github.com/awksedgreep/commonthread',
      'source_code_uri' => 'https://github.com/awksedgreep/commonthread',
      'changelog_uri' => 'https://github.com/awksedgreep/commonthread/blob/master/README.md',
      'rubygems_mfa_required' => 'true'
    }
    
    s.add_development_dependency 'rake', '~> 13.0'
    s.add_development_dependency 'minitest', '~> 5.0'
end
