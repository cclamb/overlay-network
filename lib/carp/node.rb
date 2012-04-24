require 'sinatra/base'
require 'socket'
require 'net/http'
require 'uri'

require_relative 'factory'
require_relative '../util/test_interface'

module Carp

  module Core

    class Node < Perch::Util::TestInterface

      enable :inline_templates

      @@router = nil
      @@ctx_mgr = nil
      @@content_root = nil

      def initialize
        super
        @type = 'content node'
      end

      def get_content id
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
        if bundle == nil
          puts "dispatching to router: #{@@router}"
          uri_string = "#{@@router}/route/#{id}"
          puts uri_string
          uri = URI.parse uri_string
          # response = Net::HTTP.get_response uri

          # uri = URI.parse("http://google.com/")
          # http = Net::HTTP.new(uri.host, uri.port)
          # request = Net::HTTP::Get.new(uri.request_uri)
          # request.basic_auth("username", "password")
          # response = http.request(request)

          http = Net::HTTP.new uri.host, uri.port
          request = Net::HTTP::Get.new uri.request_uri, \
            'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'node'
          response = http.request request


          puts response.inspect
          bundle = response.body if response.code == 200
        end

        halt 404 if bundle == nil

        return bundle
      end

      get '/content/:id' do
        id = params[:id]
        bundle = get_content id
        @license = bundle[:license]
        @content = bundle[:content]
        headers 'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'node'
        content_type :xml
        erb :content
      end

      get '/test/content/:id' do
        id = params[:id]
        bundle = get_content id
        @license = bundle[:license]
        @content = bundle[:content]
        headers 'X-Overlay-Port' => "#{settings.port}", 'X-Overlay-Role' => 'node'
        content_type :xml
        erb :content
      end

      def self.start params
        ctx = params[:ctx]
        set ctx if ctx != nil
        @@router = params[:router]
        @@ctx_mgr = params[:ctx_mgr]
        @@content_root = params[:content_root]

        puts "\n\n************************************\n"
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