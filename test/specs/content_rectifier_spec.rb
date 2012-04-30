require_relative '../../lib/util/content_rectifier'

ARTIFACT_FILENAME = 'etc/sample_artifact.xml'
LICENSE_FILENAME = 'etc/sample_license.xml'

def read_and_rectify rectify_level, op_size, s_size, e_size
  cr = Util::ContentRectifier.new
  artifact_xml = File.read ARTIFACT_FILENAME
  license_xml = File.read LICENSE_FILENAME
  xml = cr.rectify license_xml, artifact_xml, rectify_level
  doc = Nokogiri::XML xml[:artifact]
  ldoc = Nokogiri::XML xml[:license]
  operationals = doc.search '//artifact/test/operational'
  sources = doc.search '//artifact/test/source'
  entities = ldoc.search '//license/policy/entity'
  operationals.size.should eq op_size
  sources.size.should eq s_size
  entities.size.should eq e_size
end

describe Util::ContentRectifier do

  it 'should be creatable' do
    Util::ContentRectifier.new.should_not eq nil
  end

  it 'should handle nil submissions by returning nil' do
    cr = Util::ContentRectifier.new
    cr.rectify(nil, nil).should eq nil
    cr.rectify("", nil).should eq nil
    cr.rectify(nil, "").should eq nil
  end

  it 'should raise an error if non-string are submitted' do
    cr = Util::ContentRectifier.new
    ->() { cr.rectify 1,"" }.should raise_error
    ->() { cr.rectify "", 1 }.should raise_error
    ->() { cr.rectify 2, 1 }.should raise_error
  end

  it 'should not filter content at TS' do
    read_and_rectify :top_secret, 1, 1, 2
  end

  it 'should filter some content at S' do
    read_and_rectify :secret, 1, 0, 1
  end

  it 'should filter additional content at UC' do
    read_and_rectify :unclassified, 0, 0, 0
  end

end