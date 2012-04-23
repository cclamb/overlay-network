require 'net/http'
require 'uri'

describe 'Server Integration' do

  VALID_URI = URI.parse 'http://localhost:4567/test/content/test'
  NO_CONTENT_URI = URI.parse 'http://localhost:4567/test/content/bad-bundle'
  NO_LICENSE_URI = URI.parse 'http://localhost:4567/test/content/bogus-bundle'
  NON_EXTANT_URI = URI.parse 'http://localhost:4567/test/content/nothing-here-man'

  before :all do
    puts '(ensure node is started) '
  end
  
  it 'should return HTTP 404 if no content exists' do
    rsp = Net::HTTP.get_response NON_EXTANT_URI
    rsp.code.should eq '404'
  end

  it 'should return HTTP 500 if the bundle is poorly formatted (no content)' do
    rsp = Net::HTTP.get_response NO_CONTENT_URI
    rsp.code.should eq '500'
  end

  it 'should return HTTP 500 if the bundle is poorly formatted (no license)' do
    rsp = Net::HTTP.get_response NO_LICENSE_URI
    rsp.code.should eq '500'
  end

  it 'should return XML content with license and content' do
    rsp = Net::HTTP.get_response VALID_URI
    rsp.code.should eq '200'
    body = rsp.body
    fail 'no license' unless body =~ /license/
    fail 'no content' unless body =~ /content/
  end

  after :all do
    puts "\n(feel free to terminate node)"
  end

end