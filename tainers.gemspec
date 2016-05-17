Gem::Specification.new do |s|
  s.name        = 'tainers'
  s.version     = '0.3.0'
  s.email       = 'ethan@the-rowes.com'
  s.author      = 'Ethan Rowe'
  s.date        = '2016-05-17'
  s.platform    = Gem::Platform::RUBY
  s.description = 'Config-driven management of docker containers'
  s.summary     = 'Manage docker containers based on deterministic naming derived from container configuration'
  s.homepage    = 'http://github.com/ethanrowe/ruby-tainers'
  s.license     = 'MIT'

  s.files       = Dir.glob('lib/**/*.rb') + Dir.glob('spec/**/*.rb') + Dir.glob('bin/*') + Dir.glob('Gemfile*')

  s.executables << 'tainers'

  s.add_dependency('docker-api', '>= 1.21.4')

  s.add_development_dependency('bundler', '~> 1.7.6')
  s.add_development_dependency('rspec', '~> 3.1.0')
end
