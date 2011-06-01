module Blacklight
  module Generators
    class SitemapGenerator < Rails::Generators::Base
      desc 'Creates a configurable new rake task within Rakefile'

      def self.source_root
        @_blacklight_source_root ||= File.expand_path("../templates", __FILE__)
      end


      def create_blacklight_sitemap_task
        rakefile_path = File.join(Rails.root,'Rakefile')
        rakefile = File.read(rakefile_path)
        if rakefile.scan('Rake::BlacklightSitemapTask.new').empty?
          append_to_file(rakefile_path, File.read(File.join(File.dirname(__FILE__),'templates/default_rake_task.rb')))
        end
      end
      
    end
  end
end

