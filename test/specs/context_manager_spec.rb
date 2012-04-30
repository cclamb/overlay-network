require 'rspec'
require 'rack/test'
require 'json'

require_relative '../../lib/koi/context_manager'

def parse_response response
  JSON.parse(last_response.body)['level'].to_sym
end

def set_and_test new_level
    post '/status', {:level => new_level}
    last_response.should be_ok
    get '/status'
    last_response.should be_ok
    parse_response(last_response).should eq new_level
end

def set_and_test_unknown new_level
    get '/status'
    last_response.should be_ok
    original_level = parse_response last_response
    post '/status', {:level => new_level}
    last_response.should be_ok
    get '/status'
    last_response.should be_ok
    parse_response(last_response).should eq original_level
end

describe Koi::ContextManager do
  include Rack::Test::Methods

  def app
    Koi::ContextManager
  end

  it 'should handle get /status' do
    get '/status'
    last_response.should be_ok
    status = JSON.parse last_response.body
    status['level'].should eq 'secret'
    last_response.content_type.should eq 'application/json;charset=utf-8'
  end

  it 'should handle post /status' do
    set_and_test :secret
    set_and_test :unclassified
    set_and_test :top_secret
  end

  it 'should reject unknown settings' do
    set_and_test_unknown :foobar
    set_and_test_unknown :bar
    set_and_test_unknown :ball
    set_and_test_unknown :ts_sci
  end

end