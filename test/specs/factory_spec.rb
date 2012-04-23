require_relative '../../lib/carp/core/factory'

describe Carp::Core::Factory do
  
  it 'should be creatable' do
    Carp::Core::Factory.new.should_not eq nil
  end

  it 'should create a file system search manager' do
    f = Carp::Core::Factory.new
    sm = f.create_component :search_manager
    sm.should_not eq nil
  end

end