#!/usr/bin/env ruby
require 'nokogiri'
require 'rake'

module Rake
  class BlacklightSitemapTask
    # base url used for all locations
    attr_accessor :url
    
    # should the files be gzipped? requires the commandline tool gzip
    attr_accessor :gzip
    
    # value for changefreq for each page listed
    attr_accessor :changefreq #FIXME: not yet implemented
    
    # the most resources which should be listed within a single sitemap
    # defaults to 50,000
    attr_accessor :ceiling
    
    # Solr field that contains a date to create a lastmod date for the page
    attr_accessor :lastmod_field #FIXME: not yet implemented
    
    
    def initialize
      @url = 'http://localhost:3000'
      @ceiling = 50000 #default value for ceiling
      yield self if block_given?
      define
    end
    
    def define
      namespace :blacklight do
        desc 'create a sitemap for blacklight'
        task :sitemap => :environment do
          puts 'Creating a sitemap...'
          number_of_resources = Blacklight.solr.find({:qt => 'standard', :q => 'id:[* TO *]', :fl => :id, :rows => 1})['response']['numFound']
          puts 'Number of resources: ' + number_of_resources.to_s
          batches = (number_of_resources / @ceiling.to_f).ceil
          puts 'Total sitemap files created: ' + batches.to_s
          master_sitemap = ''
          lastmod = DateTime.now.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
          batches.times do |batch_number|
            current_page = batch_number + 1
            start = batch_number * @ceiling
            puts 'Processing batch # ' + current_page.to_s
            response = Blacklight.solr.find({:qt => 'standard', :q => 'id:[* TO *]', 
                        :fl => :id, :rows => @ceiling, :start => start})['response']
            doc_ids = response['docs'].map{|doc| doc["id"]}
            sitemap_builder = Nokogiri::XML::Builder.new do |xml|
              xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
                doc_ids.each do |id|
                  xml.url do
                    # FIXME through config
                    xml.loc File.join(@url.to_s, id)
                    xml.lastmod lastmod
                  end
                end
              end
            end
            sitemap_filename = File.join(RAILS_ROOT, 'public', 'sitemap' + batch_number.to_s + '.xml')
            File.open(sitemap_filename, 'w') do |fh|
              fh.puts sitemap_builder.to_xml
            end
            if @gzip
              `gzip #{sitemap_filename}`
            end
          end
          # creating sitemap index
          
          sitemap_index_builder = Nokogiri::XML::Builder.new do |xml|
            xml.sitemapindex 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
              batches.times do |batch|
                sitemap_filename = File.join(@url.to_s, 'sitemap' + batch.to_s + '.xml')
                sitemap_filename << '.gz' if @gzip
                xml.sitemap{
                  xml.loc sitemap_filename
                  xml.lastmod lastmod
                }
              end        
            end
          end #sitemap_index_builder
          File.open(File.join(RAILS_ROOT, 'public', 'sitemap.xml'), 'w') do |fh|
            fh.puts sitemap_index_builder.to_xml
          end
        end
      end
    end
  end
end
