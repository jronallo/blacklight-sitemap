require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BlacklightSitemap" do
  it "should create the task" do
    Rake::BlacklightSitemapTask.new
    Task['blacklight:sitemap'].should be_a_kind_of Rake::Task
  end
  
  it "should be able to have the url attribute" do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.url = 'http://example.com'
    end
    task.url.should eq('http://example.com')
  end  
  
  it 'should set the ceiling to 50,000 as a default' do
    task = Rake::BlacklightSitemapTask.new
    task.ceiling.should == 50000
  end
  
  it 'should allow the ceiling to be set to a different value' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.ceiling = 50
    end
    task.ceiling.should == 50
  end
  
  it 'should store a value for whether to gzip or not' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.gzip = true
    end
    task.gzip.should be_true
  end
end
