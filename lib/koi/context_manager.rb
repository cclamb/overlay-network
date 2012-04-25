require 'sinatra/base'
require 'socket'
require 'net/http'
require 'uri'
require 'json'

require_relative '../util/test_interface'

module Koi

  class ContextManager < Util::TestInterface

    def initialize
      super
      @status = { :level => :top_secret }
    end

    get '/status' do
      JSON.generate @status
    end

    post '/status' do

    end

  end

end