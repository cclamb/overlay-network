require_relative 'context_proxy'
require_relative '../util/content_processor'
require_relative '../util/content_rectifier'

module Trout

  class Factory

    def create_component name, args = nil
      return create_context_proxy args if name == :context_proxy
      return create_content_processor if name == :content_processor
      return create_content_rectifier if name == :content_rectifier
      raise "unrecognized component; requested #{name}"
    end

    private

    def create_context_proxy args
      ContextProxy.new args[:url]
    end

    def create_content_processor
      Util::ContentProcessor.new
    end

    def create_content_rectifier
      Util::ContentRectifier.new
    end

  end

end