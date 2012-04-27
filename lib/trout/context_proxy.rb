require 'net/http'
require 'uri'
require 'json'

module Trout

  class ContextProxy

    def initialize url
      @url = url
    end

    def status?
      uri = URI.parse @url
      response = Net::HTTP.get_response uri
      response.code == '200' \
        ? JSON.parse(response.body)['level'].to_sym \
        : :unknown_status
    end

  end

end