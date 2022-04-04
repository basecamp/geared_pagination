Gem::Specification.new do |s|
  s.name     = 'geared_pagination'
  s.version  = '1.1.1'
  s.authors  = 'David Heinemeier Hansson'
  s.email    = 'david@basecamp.com'
  s.summary  = 'Paginate Active Record sets at variable speeds'
  s.homepage = 'https://github.com/basecamp/geared_pagination'
  s.license  = 'MIT'

  s.required_ruby_version = '>= 1.9.3'

  s.add_dependency 'activesupport', '>= 5.0'
  s.add_dependency 'addressable', '>= 2.5.0'

  s.add_development_dependency 'bundler', '~> 1.12'

  s.files      = `git ls-files`.split("\n")
  s.test_files = `git ls-files -- test/*`.split("\n")
end
