require 'sinatra/base'
require 'socket'
require 'net/http'
require 'uri'


require_relative 'factory'
require_relative '../perch/util/test_interface'

module Trout

  class Router < Perch::Util::TestInterface

    enable :inline_templates

    def initialize
      super
      @type = 'router'
    end

    def search_children params
      request = params[:request]
      responses = []

      @@nodes.each do |node|
        uri_string = "#{node}/content/#{request}"
        uri = URI.parse uri_string
        begin
          response = Net::HTTP.get_response uri
          responses.push response if response.code == '200'
        rescue
        end
      end
      return responses
    end

    def process_child_request params
      puts "Processing child request\n"

      responses = search_children params

      if responses.empty?
        request = params[:request]
        # forward to any known routers
        @@routers.each do |router|
          uri_string = "#{router}/route/#{request}"
          uri = URI.parse uri_string
          begin
            response = Net::HTTP.get_response uri
            responses.push response if response.code == '200'
          rescue
          end
        end
      end

      headers 'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'router'
      if responses.size > 0
        response = responses[0]
        return response.body
      else
        halt 404
      end

    end

    def process_router_request params
      puts "Procesing router request...\n"

      responses = search_children params

      headers 'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'router'
      if responses.size > 0
        response = responses[0]
        return response.body
      else
        halt 404
      end
    end

    get '/route/:request' do
      role = request.env['HTTP_X_OVERLAY_ROLE']
      if role == 'router'
        process_router_request params
      else
        process_child_request params
      end
    end

    def self.start params
        ctx = params[:ctx]
        set ctx if ctx != nil
        @@context = params[:ctx_mgr]
        @@nodes = params[:nodes]
        @@routers = params[:routers]
        run!
    end

  end

end