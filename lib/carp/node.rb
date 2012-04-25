require 'sinatra/base'
require 'socket'
require 'net/http'
require 'uri'

require_relative 'factory'
require_relative '../util/test_interface'

module Carp

  module Core

    class Node < Util::TestInterface

      enable :inline_templates

      @@router = nil
      @@ctx_mgr = nil
      @@content_root = nil

      def initialize
        super
        @type = 'content node'
      end

      def get_content id, pass_to_router = true
        factory = Carp::Core::Factory.new
        sm = factory.create_component :search_manager, \
          :content_root => @@content_root

        bundle = nil
        begin
          bundle = sm.find id
        rescue RuntimeError => err
          halt 500, "#{err.message}\n"
        end

        # dispatch to router
        if bundle == nil && pass_to_router && @@router != nil
          uri_string = "#{@@router}/route/#{id}"
          puts "[C(#{settings.port})] dispatching to router: #{uri_string}"
          uri = URI.parse uri_string
          http = Net::HTTP.new uri.host, uri.port
          request = Net::HTTP::Get.new uri.request_uri, \
            'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'node'
          response = http.request request
          bundle = response.body if response.code == '200'
        end

        halt 404 if bundle == nil

        return bundle
      end

      get '/content/:id' do
        id = params[:id]
        role = request.env['HTTP_X_OVERLAY_ROLE']
        bundle = get_content id, role != 'router'
        headers 'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'node'
        content_type :xml
        begin
          @license = bundle[:license]
          @content = bundle[:content]
          erb :content
        rescue
          return bundle
        end
      end

      get '/test/content/:id' do
        id = params[:id]
        role = request.env['HTTP_X_OVERLAY_ROLE']
        bundle = get_content id, role != 'router'
        headers 'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'node'
        content_type :xml
        begin
          @license = bundle[:license]
          @content = bundle[:content]
          erb :content
        rescue
          return bundle
        end
      end

      def self.start params
        ctx = params[:ctx]
        set ctx if ctx != nil
        @@router = params[:router]
        @@ctx_mgr = params[:ctx_mgr]
        @@content_root = params[:content_root]

        puts "************************************\n"
        puts "Node running on port #{ctx[:port]}\n"
        puts "\troot: #{@@content_root}\n"
        puts "\trouter: #{@@router}\n"
        puts "************************************\n"

        run!
      end

    end

  end

end

__END__

@@content
<content>
  <license>
    <%= @license %>
  </license>
  <artifact>
    <%= @content %>
  </artifact>
</content>
