require_relative 'file_search_manager'

module Carp

  module Core

    class Factory

      CONTENT_ROOT = "#{File.dirname __FILE__}/../../etc/content-0"

      def create_component name, args = nil
        return create_search_manager args if name == :search_manager
        raise 'unrecognized component requested'
      end

      private

      def create_search_manager args
        puts "\t\t<< ARGS : #{args} >>\n"
        root = (args != nil && args[:content_root] != nil) ? args[:content_root] : CONTENT_ROOT
        Carp::Search::FileSearchManager.new root
      end

    end

  end

end