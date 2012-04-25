require 'sinatra/base'
require 'socket'
require 'net/http'
require 'uri'


require_relative 'factory'
require_relative '../util/test_interface'

module Trout

  class Router < Perch::Util::TestInterface

    enable :inline_templates

    @@context = nil
    @@nodes = nil
    @@routers = nil

    def initialize
      super
      @type = 'router'
    end

    def search_children params
      request = params[:request]
      responses = []

      @@nodes.each do |node|
        uri_string = "#{node}/content/#{request}"
        puts "[R(#{settings.port})] submitting to node: #{uri_string}\n"
        uri = URI.parse uri_string
        begin
          # response = Net::HTTP.get_response uri
          http = Net::HTTP.new uri.host, uri.port
          request = Net::HTTP::Get.new uri.request_uri, \
            'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'router'
          response = http.request request
          responses.push response if response.code == '200'
        rescue
        end
      end
      return responses
    end

    def process_child_request params, port
      puts "[R(#{settings.port})] child request from port: #{port}\n"

      # Generally need to search other children first,
      # but not needed now
      #
      # responses = search_children params
      responses = []

      if responses.empty? && @@routers != nil
        request = params[:request]
        @@routers.each do |router|
          uri_string = "http://localhost:#{router}/route/#{request}"
          uri = URI.parse uri_string
          puts "[R(#{settings.port})] forwarding to #{uri_string}"
          begin
            http = Net::HTTP.new uri.host, uri.port
            request = Net::HTTP::Get.new uri.request_uri, \
              'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'router'
            response = http.request request
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
      puts "[R(#{settings.port})] processing router request...\n"

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
        port = request.env['HTTP_X_OVERLAY_PORT']
        process_child_request params, port
      end
    end

    def self.start params
        ctx = params[:ctx]
        set ctx if ctx != nil
        @@context = params[:ctx_mgr]
        @@nodes = params[:nodes]
        @@routers = params[:routers]

        puts "************************************\n"
        puts "Router running on port #{ctx[:port]}\n"
        puts "\tchildren: #{@@nodes}\n"
        puts "\trouters: #{@@routers}\n"
        puts "************************************\n"

        run!
    end

  end

end