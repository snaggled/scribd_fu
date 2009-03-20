require File.dirname(__FILE__) + '/spec_helper'

# I guess we probably want to do the following:
#
# 1. check for scribd_config.yml, has valid values, and that we can login properly
# 2. check for paperclip or attachment_fu and use the correct methods
# 2. create a scribd document and check the various scribd properties
# 3. make sure we clean up anything we sent to scribd
#
# TODO - we're not checking any of the view helpers here (e.g. display_scribd)
# nor are we testing any S3 functionality
# Also tbd - maybe put in some direct rscribd calls to very the scribd destroys etc

describe "The scribd_config.xml file" do

  it "should be in the /config dir" do
    File.exist?(File.expand_path(scribd_yaml)).should be_true
  end
  
  before(:all) {@scribd_config = YAML.load_file(scribd_yaml).symbolize_keys[:scribd]}

  # assuming blank values are bad ?
  it "should have values populated" do      
    @scribd_config.each {|k,v| v.should_not be_nil}
  end

  # this is from scribd_fu.rb - maybe we'd just be better to let the lib handle this
  # when a record is created rather than explicitly testing here
  it "should result in a valid scribd login" do
    Scribd::API.instance.key    = @scribd_config['key'].to_s.strip
    Scribd::API.instance.secret = @scribd_config['secret'].to_s.strip
    user = @scribd_config['user'].to_s.strip
    password = @scribd_config['password'].to_s.strip
    lambda {Scribd::User.login user, password}.should_not raise_error
  end
  
end

describe "A scribd account" do

  before(:each) do
    @scribd_config = YAML.load_file(scribd_yaml).symbolize_keys[:scribd]
  end
  
  describe "with private access level" do

    before do 
      @scribd_config[:access] = :private
      @doc = ScribdDocumentProxy.new
    end
    
    it "should create private documents" do
      @doc.access_level.should == "private"
    end
        
  end
  
  describe "with public access level" do
    
    before do 
      @scribd_config[:access] = :public
      @doc = ScribdDocumentProxy.new
    end

      it "should create public documents" do
        @doc.access_level.should == "private"        
      end

    end
    
  after(:each) {@doc.destroy_scribd_documents}
    
end

describe "A scribd document" do
    
  before(:all) {@scribd_config = YAML.load_file(scribd_yaml).symbolize_keys[:scribd]}

  describe "with a valid mime type" do

    before(:each) {@doc = ScribdDocumentProxy.new}
    
    it "should have an attached scribd document" do
      @doc.scribd_id.should_not be_nil
      @doc.scribd_id.should > 0
    end
    
    it "should be scribdable" do
      @doc.scribdable?.should be_true
    end
    
    it "should have a thumbnail url" do
      @doc.thumbnail_url.should_not be_nil
    end
    
    # TODO - maybe conversion complete and/or successful
    it "should not have a conversion status of error" do
      @doc.conversion_error?.should == false
    end
    
    it "should be removed from scribd upon destruction" do
      # we don't really have any of testing this because the destroy_scribd_documents
      # doesn't reset any model attributes. 
      # TODO - set scribd_id & scribd_access_key to nil in destroy_scribd_documents,
      # then we can test
      # @doc.destroy
      # @doc.document_scribd_id.should be_nil
    end
    
    after(:each) {@doc.destroy_scribd_documents}
    
  end
  
  describe "with an invalid mime type" do

    it "should be rejected by scribd and fail validation" do
      lambda {ScribdDocumentProxy.new('rails.png', 'image/png')}.should raise_error
    end
        
  end
  
  describe "that is of length zero" do

    it "should be rejected and fail validation" do
      lambda {ScribdDocumentProxy.new('test.txt', 'plain/text')}.should raise_error
    end
    
  end
  
  describe "that has no mime type" do

    it "should be rejected and fail validation" do
      lambda {ScribdDocumentProxy.new('blank', '')}.should raise_error
    end
    
  end
  
end