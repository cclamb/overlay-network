require_relative 'file_search_manager'

module Carp

  module Core

    class Factory

      CONTENT_ROOT = "#{File.dirname __FILE__}/../../etc/content"

      def create_component name, args = nil
        return create_search_manager args if name == :search_manager
        raise 'unrecognized component requested'
      end

      private

      def create_search_manager args
        root = (args != nil && args[:content_root] != nil) ? args[:content_root] : CONTENT_ROOT
        Carp::Search::FileSearchManager.new CONTENT_ROOT
      end

    end

  end

end