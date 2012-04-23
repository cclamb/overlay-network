
module Trout

  class Factory

    CONTENT_ROOT = 'etc/content'

    def create_component name
      return create_search_manager if name == :search_manager
      raise 'unrecognized component requested'
    end

    private

    def create_search_manager
    end

  end

end