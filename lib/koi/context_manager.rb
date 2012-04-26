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

    def validate_level level
      level == :secret \
        || level == :top_secret \
        || level == :unclassified
    end

    get '/status' do
      JSON.generate @status
    end

    post '/status' do
      new_level = params[:level].to_sym
      return unless validate_level new_level
      @status[:level] = new_level.to_sym
    end

  end

end