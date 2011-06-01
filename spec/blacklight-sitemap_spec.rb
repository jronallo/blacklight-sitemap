require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BlacklightSitemap" do
  before(:all) do
    @default_task = Rake::BlacklightSitemapTask.new
  end

  it 'should create a default task which clobbers then creates' do
    Rake::BlacklightSitemapTask.new
    Rake::Task['blacklight:sitemap'].should be_a_kind_of Rake::Task
  end

  it "should create the sitemap creation task" do
    Rake::BlacklightSitemapTask.new
    Rake::Task['blacklight:sitemap:create'].should be_a_kind_of Rake::Task
  end

  it "should be able to have the url attribute" do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.url = 'http://example.com'
    end
    task.url.should eq('http://example.com')
  end

  it 'should have a base_filename attribute' do
    @default_task.base_filename.should eq('blacklight')
  end

  it 'should allow for changing the base_filename attribute' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.base_filename = 'bl'
    end
    task.base_filename.should eq('bl')
  end

  it 'should store a value for whether to gzip or not' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.gzip = true
    end
    task.gzip.should be_true
  end

  it 'should have a default nil value for changefreq' do
    @default_task.changefreq.should be_nil
  end

  it 'should allow for changing the changefreq value' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.changefreq = 'never'
    end
    task.changefreq.should eq('never')
  end

  it 'should set the ceiling to 50,000 as a default' do
    @default_task.max.should == 50000
  end

  it 'should allow the ceiling to be set to a different value' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.max = 50
    end
    task.max.should == 50
  end

  it 'should have a default value for the lastmod_field' do
    @default_task.lastmod_field.should eq('timestamp')
  end

  it 'should allow a new value for lastmod_field' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.lastmod_field = 'date_created'
    end
    task.lastmod_field.should eq('date_created')
  end

  it 'should have a default value for the priority_field' do
    @default_task.priority_field.should be_nil
  end

  it 'should allow a new value for priority_field' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.priority_field = 'priority'
    end
    task.priority_field.should eq('priority')
  end

  it 'should have a default value for sorting the Solr query' do
    @default_task.sort.should eq('_docid_ asc')
  end

  it 'should be able to set a new value for sort' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.sort = 'timestamp asc'
    end
    task.sort.should eq('timestamp asc')
  end
  
  it 'should be able to set a new value for qt' do
    task = Rake::BlacklightSitemapTask.new do |sm|
      sm.qt = 'bozart'
    end
    task.qt.should eq('bozart')
  end

  it 'should create the sitemap clobber task' do
    Rake::BlacklightSitemapTask.new
    Rake::Task['blacklight:sitemap:clobber'].should be_a_kind_of Rake::Task
  end

end

