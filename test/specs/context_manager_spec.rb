require 'rspec'
require 'rack/test'
require 'json'

require_relative '../../lib/koi/context_manager'

describe Koi::ContextManager do
  include Rack::Test::Methods

  def app
    Koi::ContextManager
  end

  it 'should handle get /status' do
    get '/status'
    last_response.should be_ok
    status = JSON.parse last_response.body
    status['level'].should eq 'top_secret'
  end

  it 'should handle post /status' do
    post '/status'
    last_response.should be_ok
  end

end