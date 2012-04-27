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
      level != nil \
        && ( level == :secret \
          || level == :top_secret \
          || level == :unclassified )
    end

    get '/status' do
      content_type 'application/json', :charset => 'utf-8'
      JSON.generate @status
    end

    post '/status' do
      new_level = params[:level]
      return if new_level == nil
      new_level = new_level.to_sym
      return unless validate_level new_level
      @status[:level] = new_level.to_sym
    end

    def self.start params
        ctx = params[:ctx]
        set ctx if ctx != nil

        puts "************************************\n"
        puts "Context Manager running on port #{ctx[:port]}\n"
        puts "************************************\n"

        run!
      end

  end

end