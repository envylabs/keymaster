source 'https://rubygems.org'

ruby "1.9.3"

gem 'rails', '3.2.14'
gem 'friendly_id', '~> 4.0'
gem 'rack-response-signature', :require => 'rack/response_signature'
gem 'pg', '~> 0.16.0'

group :production do
  gem 'unicorn', '~> 4.6'
end

group :test do
  gem 'shoulda', '~> 3.5'
  gem 'mocha', :require => 'mocha/setup'
  gem 'factory_girl_rails', '~> 4.2'
end
