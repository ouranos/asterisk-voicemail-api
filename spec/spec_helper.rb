require 'rubygems'
require 'sinatra'
require 'rack/test'
require 'spec'
require 'spec/autorun'
require 'spec/interop/test'
require 'factory_girl'

# Set test environment
set :environment, :test
set :run, false
set :raise_errors, true
set :logging, false

require File.join(File.dirname(__FILE__), '..', 'voicemail-api.rb')

