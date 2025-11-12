# spec/simplecov_helper.rb
require 'simplecov'

SimpleCov.profiles.define 'rails_custom' do
  load_profile 'rails'
end

SimpleCov.start 'rails_custom' do
  add_filter '/spec/'
  add_filter '/features/'
end
