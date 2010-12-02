require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BlacklightSitemap" do
  it "should create a task" do
    Rake::BlacklightSitemapTask.new
    Task['blacklight:sitemap'].should be_a_kind_of Rake::Task
  end
end
