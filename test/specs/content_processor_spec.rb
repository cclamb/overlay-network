require 'nokogiri'

require_relative '../../lib/util/content_processor'

CONTENT_FILE = 'etc/sample_content.xml'

describe Util::ContentProcessor do 

  it 'should be creatable' do
    cp = Util::ContentProcessor.new
    cp.should_not eq nil
  end

  it 'should return nil on submitted nil' do
    cp = Util::ContentProcessor.new
    cp.split(nil).should eq nil
  end

  it 'should fail on non-string input' do
    cp = Util::ContentProcessor.new
    ->() { cp.split 1 }.should raise_error
  end

  it 'should split XML' do
    xml = File.read CONTENT_FILE
    cp = Util::ContentProcessor.new
    result = cp.split xml
    result[:artifact].should_not eq nil
    license_doc = Nokogiri::XML result[:license]
    artifact_doc = Nokogiri::XML result[:artifact]
    bad_artifact_nodes = license_doc.xpath '//license/artifact'
    bad_artifact_nodes.size.should eq 0
    entity_nodes = license_doc.xpath '//license/policy/entity'
    entity_nodes.size.should eq 2
    source_nodes = artifact_doc.xpath '//artifact/test/source'
    operational_nodes = artifact_doc.xpath '//artifact/test/operational'
    source_nodes.size.should eq 1
    operational_nodes.size.should eq 1
  end

  it 'should unify XML' do
    xml = File.read CONTENT_FILE
    cp = Util::ContentProcessor.new
    result = cp.split xml
    result[:artifact].should_not eq nil
    license_doc = Nokogiri::XML result[:license]
    artifact_doc = Nokogiri::XML result[:artifact]
    unify_xml =  cp.unify license_doc.to_s, artifact_doc.to_s
    unify_doc = Nokogiri::XML unify_xml
    unify_doc.search('//content').size.should eq 1
    unify_doc.search('//license').size.should eq 1
    unify_doc.search('//artifact').size.should eq 1
  end

end
