require 'sinatra/base'

module Perch

  module Util

    class TestInterface < Sinatra::Base

      enable :inline_templates

      def initialize
        super
        @hostname = Socket.gethostname
        @type = ''
      end

      get '/test/error/404' do
        halt 404
      end

      get '/test/error/500' do
        halt 500
      end

      get '/test/*' do
        msg = params[:splat]
        content_type :txt
        "Howdy! This is the #{@type} node on #{@hostname}; msg = #{msg}."
      end

      get '/test' do
        content_type :txt
        "Howdy! This is the #{@type} node on #{@hostname}."
      end

      get '/' do
        erb :index
      end

    end

  end

end

__END__

@@index

<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8">
    <title><%= @hostname %> : Overlay Node</title>
  </head>
  <body>
    <p>
    <b>This is the <%= @type %> node on <%= @hostname %>.</b>
    </p>
  </body>
</html>