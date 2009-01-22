require File.join(File.dirname(__FILE__), 'test_helper')

describe EnhancedMemCacheStore do
  
  before(:each) do
    @memcache = EnhancedMemCacheStore.new('localhost:11211', :readonly => false)
    @memcache.clear
  end
  
  it "should store the a list of keys of everything written to the cache" do  
    @memcache.write('argle', 'argledata')
    @memcache.write('bargle', 'bargledata')
    @memcache.write('bargles', 'barglesdata')
    
    @memcache.keys.should include('argle')
    @memcache.keys.should include('bargle')
    @memcache.keys.should include('bargles')
  end
  
  it "should not update key list if store an expirable item" do
    @memcache.write('argle', 'argledata', :expires_in => 5.minutes).should be_true
    @memcache.read('argle').should == 'argledata'
    
    @memcache.keys.should_not include('argle')
  end
  
  describe "when writing to cache" do
    it "should write data to give key" do
      @memcache.write('argle', 'argledata').should be_true
      @memcache.read('argle').should == 'argledata'
    end
    
    it "should add this key to cached keys" do
      @memcache.write('argle', 'argledata').should be_true
      @memcache.keys.should include('argle')
    end
  end
  
  describe "when deleting from cache" do
    before(:each) do        
      @memcache.write('argle', 'argledata').should be_true
      @memcache.write('bargle', 'bargledata').should be_true
      @memcache.write('bargles', 'barglesdata').should be_true
      
      %w[argle bargle bargles].each { |k| @memcache.keys.should include(k) }
    end
    
    describe "when deleting specific keys" do
      it "should delete key from cache" do
        @memcache.delete('bargle').should be_true
        @memcache.delete('bargles').should be_true
        @memcache.read('bargle').should be_nil
        @memcache.read('bargles').should be_nil
        @memcache.read('argle').should == 'argledata'
      end
      
      it "should remove key from cached keys" do
        @memcache.delete('bargle').should be_true
        @memcache.delete('bargles').should be_true
        @memcache.keys.should include('argle')
        @memcache.keys.should_not include('bargle')
        @memcache.keys.should_not include('bargles')
      end
    end
    
    describe "when deleting matched keys" do      
      it "should delete matched keys from cache" do
        @memcache.delete_matched(/bargle/).should be_true
        @memcache.read('bargle').should be_nil
        @memcache.read('bargles').should be_nil
        @memcache.read('argle').should == 'argledata'
      end
      
      it "should remove matched keys from cached keys" do
        @memcache.delete_matched(/bargle/).should be_true
        @memcache.keys.should include('argle')
        @memcache.keys.should_not include('bargle')
        @memcache.keys.should_not include('bargles')
      end
    end
  end
end