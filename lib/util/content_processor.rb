require 'nokogiri'

module Util

  class ContentProcessor

    def split xml
      return nil if xml == nil
      doc = Nokogiri::XML xml
      license_clazz = doc.xpath '//content/license'
      artifact_clazz = doc.xpath '//content/artifact'
      {:license => license_clazz[0].to_s, \
        :artifact => artifact_clazz[0].to_s}
    end

    def unify license_xml, artifact_xml
      return nil if license_xml == nil || artifact_xml == nil
      license_doc = Nokogiri::XML license_xml
      artifact_doc = Nokogiri::XML artifact_xml
      content_doc = Nokogiri::XML '<content></content>'
      content_node = content_doc.search '//content'
      license_node = license_doc.search '//license'
      artifact_node = artifact_doc.search '//artifact'
      content_node[0].add_child license_node
      content_node[0].add_child artifact_node
      content_doc.to_xml
    end

  end

end