source 'https://rubygems.org'

gem 'rails', '3.2.8'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'sqlite3'


# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
 gem 'unicorn'

# Deploy with Capistrano
group :development do
  gem 'capistrano', :require => false
  gem 'capistrano-unicorn', :require => false
end

# To use debugger
# gem 'debugger'

gem "mysql2"
gem "xmpp4r", "~> 0.5"
gem "eventmachine", "~> 1.0.0"

# sidekiq and monitor request
gem "sidekiq", "~> 2.4.0"
gem "sinatra", :require => nil
gem "slim"

gem "hpricot"

group :test, :development do
  gem "pry"
  gem "pry_debug"
  gem "pry-rails"
  gem "rb-fsevent"
  gem "growl"
  gem "pow"
  gem "factory_girl_rails"
  gem "rspec-rails", "~> 2.11.4"
end

group :test do
  gem "guard-pow"
  gem "guard-rspec"
  gem "guard-spork"
  gem "guard-bundler"
  gem "database_cleaner"
end

gem "nokogiri", "~> 1.5.5"
gem "foreman"
