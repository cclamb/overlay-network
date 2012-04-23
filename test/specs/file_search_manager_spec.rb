require 'rspec'

require_relative '../../lib/carp/file_search_manager'

NON_EXISTENT_ROOT = 'non-extant'

describe Carp::Search::FileSearchManager do

  it 'should be creatable' do
    fsm = Carp::Search::FileSearchManager.new
    fsm.should_not eq nil
  end

  context 'with a non-existent document root' do
    it 'should not be creatable' do
      is_failed = false
      begin
        Carp::Search::FileSearchManager.new NON_EXISTENT_ROOT
      rescue
        is_failed = true
      end
      is_failed.should eq true
    end
  end

  context 'with a valid root, but no bundle' do

    it 'should be creatable' do
      Carp::Search::FileSearchManager.new 'etc/content'
    end

    it 'should return false from exists?' do
      fsm = Carp::Search::FileSearchManager.new 'etc/content'
      fsm.exists?('non-extant').should eq false
    end

    it 'should return nil from find' do
      fsm = Carp::Search::FileSearchManager.new 'etc/content'
      fsm.find('non-extant').should eq nil
    end

  end

  context 'with a valid root and a invalid bundle (no content)' do

    it 'should return true from exists?' do
      fsm = Carp::Search::FileSearchManager.new 'etc/content'
      fsm.exists?('bad-bundle').should eq true
    end

    it 'should throw an exception from find' do
      fsm = Carp::Search::FileSearchManager.new 'etc/content'
      is_failed = false
      begin
        fsm.find('bad-bundle').should eq nil
      rescue
        is_failed = true
      end
      is_failed.should eq true
    end

  end

  context 'with a valid root and a invalid bundle (no license)' do

    it 'should return true from exists?' do
      fsm = Carp::Search::FileSearchManager.new 'etc/content'
      fsm.exists?('bogus-bundle').should eq true
    end

    it 'should throw an exception from find' do
      fsm = Carp::Search::FileSearchManager.new 'etc/content'
      is_failed = false
      begin
        fsm.find('bogus-bundle').should eq nil
      rescue
        is_failed = true
      end
      is_failed.should eq true
    end

  end

  context 'with a valid root and a valid bundle' do

    it 'should return a licence and content' do
      fsm = Carp::Search::FileSearchManager.new 'etc/content'
      fsm.exists?('test').should eq true
      bundle = fsm.find 'test'
      bundle[:license].should_not eq nil
      bundle[:content].should_not eq nil
      bundle[:content_type].should eq :xml
      bundle[:license_type].should eq :xml
    end

  end

end