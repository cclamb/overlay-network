module Carp

  module Search

    class FileSearchManager

      def initialize root = '.'
        raise 'non-existant root' unless File.directory? root
        @root = root
      end

      def exists? name
        File.exists? bundle_root name
      end

      def find name
        bundle = "#{@root}/#{name}"
        return nil unless File.directory? bundle

        lic_name = "#{bundle}/#{name}.lic"
        art_name = "#{bundle}/#{name}.xml"
        raise 'incorrect bundle format; no license' unless File.exist? lic_name
        raise 'incorrect bundle format; no artifact' unless File.exist? art_name

        lic = File.read lic_name
        art = File.read art_name

        return {:content => art, :license => lic, :content_type => :xml, :license_type => :xml}
      end

      private

      def bundle_root name
        "#{@root}/#{name}"
      end

    end

  end

end