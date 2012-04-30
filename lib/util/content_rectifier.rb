require 'nokogiri'

module Util

  class ContentRectifier

    @@Ordering = [:unclassified, :secret, :top_secret]

    def rectify license, artifact, level = :unclassified

      return nil if license == nil || artifact == nil

      license_doc = Nokogiri::XML license
      artifact_doc = Nokogiri::XML artifact

      sensitives = get_sensitives license_doc
      sensitives.each do |sensitive|

        restrictions = sensitive.search 'restriction'
        restrictions.each do |restriction|

          if restriction[:property] == 'transmit'
            #puts "R: #{restriction[:function]} #{restriction.content}\n"

            ok_to_xmit = evaluate restriction[:function], \
            level, restriction.content.strip

            if !ok_to_xmit
              #puts "//*/#{sensitive[:name]}"
              artifact_doc.search("//*/#{sensitive[:name]}").each do |node|
                #puts node.to_s
                node.remove
                sensitive.remove
              end
            end

          end

        end

      end
      {:license => license_doc.to_xml, :artifact => artifact_doc.to_xml}
    end

    def get_sensitives doc
      doc.xpath '//*/entity'
    end

    def evaluate relation, content_level, link_level
      # puts "#{relation} : #{link_level} : #{content_level}"
      content_level = content_level.to_sym
      link_level = link_level.to_sym
      case relation.to_sym
        when :less_than
          ordering(content_level) < ordering(link_level)
        when :greater_than
          ordering(content_level) > ordering(link_level)
        when :equal
          ordering(content_level) == ordering(link_level)
        else raise 'unknown function type'
      end
    end

    def ordering level
       @@Ordering.index level
    end


  end

end