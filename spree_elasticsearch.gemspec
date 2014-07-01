# encoding: UTF-8
Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_elasticsearch'
  s.version     = '2.2.2'
  s.summary     = 'Adds basic search via elasticsearch'
  s.description = 'Indexes and makes product objects searchable'
  s.required_ruby_version = '>= 1.9.3'

  s.author    = 'Kenley Tomlin'
  s.email     = 'kenleytomlin@gmail.com'
  s.homepage  = 'https://github.com/casualsteps/'

  #s.files       = `git ls-files`.split("\n")
  #s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_core', '~> 2.2.2'
  s.add_dependency 'elasticsearch-model'
  s.add_dependency 'elasticsearch-rails'

  s.add_development_dependency 'capybara', '~> 2.1'
  s.add_development_dependency 'coffee-rails'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'factory_girl', '~> 4.4'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails',  '~> 2.13'
  s.add_development_dependency 'sass-rails'
  s.add_development_dependency 'selenium-webdriver'
  s.add_development_dependency 'simplecov'
  s.add_development_dependency 'sqlite3'
end
