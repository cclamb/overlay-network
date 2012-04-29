require 'nokogiri'

module Util

  class ContentProcessor

    def split xml
      return nil if xml == nil
      doc = Nokogiri::XML xml
      license_clazz = doc.xpath '//license'
      artifact_clazz = doc.xpath '//artifact'
      {:license => license_clazz.to_s, \
        :artifact => artifact_clazz.to_s}
    end

  end

end