require 'rspec'
require 'rack/test'
require 'socket'

require_relative '../../lib/util/test_interface'

Hostname = Socket::gethostname

describe Perch::Util::TestInterface do
  include Rack::Test::Methods

  def app
    Perch::Util::TestInterface
  end

  it 'should return 404 when error 404 called' do
    get '/test/error/404'
    last_response.should_not be_ok
    last_response.status.should eq 404
  end

  it 'should return 500 when error 500 called' do
    get '/test/error/500'
    last_response.should_not be_ok
    last_response.status.should eq 500
  end

  it 'should return a message' do
    get '/test/foobar'
    last_response.should be_ok
    fail 'no howdy' unless last_response.body =~ /Howdy/
    fail 'no foobar' unless last_response.body =~ /foobar/
  end

  it "should say hello" do
    get '/test'
    last_response.should be_ok
    body = last_response.body
    fail 'incorrect body' unless body =~ /Howdy/
  end

  it 'should return basic information from the root' do
    get '/'
    last_response.should be_ok
    fail 'incorrect body' unless last_response.body =~ /node/
  end

end