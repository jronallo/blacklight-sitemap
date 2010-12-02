#!/usr/bin/env ruby
require 'nokogiri'
require 'rake'

module Rake
  class BlacklightSitemapTask
    def initialize
      define
    end
    
    def define
      namespace :blacklight do
        desc 'create a sitemap for blacklight'
        task :sitemap => :environment do
          puts 'Creating a sitemap...'
          number_of_resources = Blacklight.solr.find({:qt => 'standard', :q => 'id:[* TO *]', :fl => :id, :rows => 1})['response']['numFound']
          puts 'Number of resources: ' + number_of_resources.to_s
          batches = (number_of_resources / 50000.0).ceil
          puts 'Total sitemap files created: ' + batches.to_s
          master_sitemap = ''
          lastmod = DateTime.now.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
          batches.times do |batch_number|
            current_page = batch_number + 1
            start = batch_number * 50000
            puts 'Processing batch # ' + current_page.to_s
            response = Blacklight.solr.find({:qt => 'standard', :q => 'id:[* TO *]', 
                        :fl => :id, :rows => 50000, :start => start})['response']
            doc_ids = response['docs'].map{|doc| doc["id"]}
            sitemap_builder = Nokogiri::XML::Builder.new do |xml|
              xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
                doc_ids.each do |id|
                  xml.url do
                    # FIXME through config
                    xml.loc id
                    xml.lastmod lastmod
                  end
                end
              end
            end
            File.open(File.join(RAILS_ROOT, 'public', 'sitemap' + batch_number.to_s + '.xml'), 'w') do |fh|
              fh.puts sitemap_builder.to_xml
            end
          end
          # creating sitemap index
          
          sitemap_index_builder = Nokogiri::XML::Builder.new do |xml|
            xml.sitemapindex 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
              batches.times do |batch|
                xml.sitemap{
                  xml.loc 'sitemap' + batch.to_s + '.xml'
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
