require 'rspec'
require 'rack/test'

require_relative '../../lib/carp/core/node'

def get_content path
  get path
  last_response.should be_ok
  fail 'no license' unless last_response.body =~ /license/
  fail 'no content' unless last_response.body =~ /content/
end

def get_404 path
  get path
  last_response.status.should eq 404
end

def get_500 path
  get path
  last_response.status.should eq 500
end

describe Carp::Core::Node do
  include Rack::Test::Methods

  def app
    Carp::Core::Node
  end

  it "should integrate the test interface" do
    get '/test'
    last_response.should be_ok
    body = last_response.body
    fail 'incorrect body' unless body =~ /Howdy/
  end

  context 'when using the test interface' do

    it 'should retrieve content' do
      get_content '/test/content/test'
    end

    it 'should return 404 for non-existant content' do
      get_404 '/test/content/non-existant'
    end

    it 'should return 505 for malformed content' do
      get_500 '/test/content/bad-bundle'
      get_500 '/test/content/bogus-bundle'
    end

  end

  context 'when using the standard interface' do

    it 'should retrieve content' do
      get_content '/content/test'
    end

    it 'should return 404 for non-existant content' do
      get_404 '/content/non-existant'
    end

    it 'should return 505 for malformed content' do
      get_500 '/content/bad-bundle'
      get_500 '/content/bogus-bundle'
    end

  end

end