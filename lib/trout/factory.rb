
module Trout

  class Factory

    def create_component name
      return create_context_proxy if name == :context_proxy
      raise 'unrecognized component requested'
    end

    private

    def create_context_proxy
    end

  end

end