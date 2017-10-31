source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem 'rails', '~> 5.1.3'
gem 'pg', '~> 0.18'
gem 'puma', '~> 3.7'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'jbuilder', '~> 2.5'
gem 'webpacker'
gem 'dotenv-rails', groups: [:development, :test]
gem 'trestle'
gem 'trestle-auth'
gem 'grape'
gem 'grape_on_rails_routes'
gem 'grape-entity'
gem 'grape_logging'
gem 'grape-middleware-logger'
gem 'carrierwave', '~> 1.0'
gem 'que'
gem 'rest-client'
gem 'nokogiri'
gem 'scenic'
gem 'active_record_union'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.6'
  gem 'airborne'
  gem 'factory_girl_rails', '~> 4.0'
  gem 'webmock'
  gem 'hirb'
  gem 'wirble'
end

group :development do
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'guard-rspec', require: false
end
