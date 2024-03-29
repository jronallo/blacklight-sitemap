#!/usr/bin/env ruby
require 'nokogiri'
require 'rake'
require 'fileutils'

# allow this to work for rake 0.8.7 and 0.9.x without deprecation warnings
begin
  include Rake::DSL
rescue
end

module Rake
  class BlacklightSitemapTask
    # base url used for locations of resources
    attr_accessor :resource_url
    
    # base url used for public directory where sitemaps will be placed
    attr_accessor :public_url

    # base filename to use for sitemap in case these will be moved to a location
    # that hosts other sitemaps so these sitemaps do not overwrite others
    attr_accessor :base_filename

    # should the files be gzipped? requires the commandline tool gzip
    attr_accessor :gzip

    # value for changefreq for each page listed
    attr_accessor :changefreq

    # the most resources which should be listed within a single sitemap
    # defaults to 50,000
    attr_accessor :max

    # Solr field that contains a date to create a lastmod date for the page.
    # Currently must be a string as in W3C Datetime format or YYYY-MM-DD
    attr_accessor :lastmod_field

    # Solr field to use to provide a priority for this resource
    attr_accessor :priority_field

    # Solr sort option
    attr_accessor :sort
    
    # pick a request handler. 
    attr_accessor :qt

    def initialize
      @resource_url = 'http://localhost:3000/catalog'
      @public_url = 'http://localhost:3000'
      
      @base_filename = 'blacklight'
      @gzip = false
      @changefreq = nil
      @max = 50000 #default value for max number of locs per sitemap file
      @lastmod_field = 'timestamp'
      @priority_field = nil
      @sort = '_docid_ asc' # http://osdir.com/ml/solr-user.lucene.apache.org/2010-03/msg01371.html
      @qt = 'standard'
      yield self if block_given?
      define
    end

    def define
      namespace :blacklight do
        desc 'clobber then create sitemap files for blacklight'
        task :sitemap => ['sitemap:clobber', 'sitemap:create']

        namespace :sitemap do

          desc 'create a sitemap for blacklight'
          task :create => :environment do
            start_time = Time.now

            #collect warnings here rather than raise an error
            warnings = []

            blacklight_config = CatalogController.blacklight_config

            puts 'Creating a sitemap...'
            fl = ['id', @lastmod_field, @priority_field].compact.join(',')
            base_solr_parameters = {:qt => @qt, :fq => 'id:[* TO *]', :fl => fl}
            repo = Blacklight::Solr::Repository.new(blacklight_config)
            response = repo.search(base_solr_parameters.merge(:rows => 1))
            number_of_resources = response['response']['numFound']
            puts 'Number of resources: ' + number_of_resources.to_s
            batches = (number_of_resources / @max.to_f).ceil
            puts 'Total sitemap to create: ' + batches.to_s
            master_sitemap = ''
            base_solr_parameters.merge!(:sort => @sort) if @sort

            # create a hash of batches with lastmod dates so that the most recent
            # lastmod date shows up associated with that batch. This will feed
            # into the lastmod for each sitemap in the index sitemap.
            batch_lastmods = {}

            batches.times do |batch_number|
              current_page = batch_number + 1
              start = batch_number * @max
              puts 'Processing batch # ' + current_page.to_s
              repo = Blacklight::Solr::Repository.new(blacklight_config)
              response = repo.search(base_solr_parameters.merge(:rows => @max, :start => start))['response']
              sitemap_builder = Nokogiri::XML::Builder.new do |xml|
                xml.urlset "xmlns" => "http://www.sitemaps.org/schemas/sitemap/0.9" do
                  response['docs'].each do |doc|
                    xml.url do
                      # FIXME through config
                      xml.loc File.join(@resource_url.to_s, doc['id'])
                      if @lastmod_field and doc[@lastmod_field]
                        xml.lastmod doc[@lastmod_field].to_s
                        if batch_lastmods[batch_number].blank? or batch_lastmods[batch_number] < doc[@lastmod_field]
                          batch_lastmods[batch_number] = doc[@lastmod_field]
                        end
                      end
                      xml.priority doc[@priority_field] if @priority_field and doc[@priority_field]
                      xml.changefreq @changefreq if @changefreq
                    end
                  end
                end
              end
              sitemap_filename = File.join(Rails.root, 'public', @base_filename + '-sitemap' + batch_number.to_s + '.xml')
              File.open(sitemap_filename, 'w') do |fh|
                fh.puts sitemap_builder.to_xml
              end
              if File.size(sitemap_filename) > 10485760
                warnings << 'WARNING Sitemap is over 10MB limit: ' + sitemap_filename
              end
              if @gzip
                `gzip #{sitemap_filename}`
              end
            end
            puts 'Creating sitemap index...'
            rake_run_lastmod = DateTime.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
            sitemap_index_builder = Nokogiri::XML::Builder.new do |xml|
              xml.sitemapindex 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
                batches.times do |batch|
                  sitemap_filename = File.join(@public_url.to_s, @base_filename + '-sitemap' + batch.to_s + '.xml')
                  sitemap_filename << '.gz' if @gzip
                  xml.sitemap{
                    xml.loc sitemap_filename
                    if batch_lastmods[batch]
                      xml.lastmod batch_lastmods[batch]
                    else
                      xml.lastmod rake_run_lastmod
                    end
                  }
                end
              end
            end #sitemap_index_builder
            index_sitemap_filename = File.join(Rails.root, 'public', @base_filename + '-sitemap.xml')
            File.open(index_sitemap_filename, 'w') do |fh|
              fh.puts sitemap_index_builder.to_xml
            end
            if File.size(index_sitemap_filename) > 10485760
              warnings << 'WARNING Index sitemap is over 10MB limit: ' + index_sitemap_filename
            end
            puts 'Done.'
            end_time = Time.now
            puts 'Create start time: ' + start_time.to_s
            puts 'Create end time:   ' + end_time.to_s
            puts 'Execution time in seconds: ' + (end_time - start_time).to_s
            puts warnings.join("\n")
          end # task :sitemap

          desc 'clobber sitemap files'
          task :clobber do
            puts "Deleting all sitemap files..."
            Dir.glob(File.join(Rails.root, 'public', @base_filename + '-sitemap*')).each do |sitemap|
              FileUtils.rm(sitemap)
            end
          end

        end # namespace :sitemap
      end # namespace :blacklight
    end # define
  end # BlacklightSitemapTask
end # Rake

