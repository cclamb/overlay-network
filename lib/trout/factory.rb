require_relative 'context_proxy'

module Trout

  class Factory

    def create_component name, args
      return create_context_proxy args if name == :context_proxy
      raise 'unrecognized component requested'
    end

    private

    def create_context_proxy args
      return ContextProxy.new args[:url]
    end

  end

end