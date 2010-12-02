class BlacklightSitemapGenerator < Rails::Generator::Base
  def initialize(*runtime_args)
    super
  end

  def manifest
    record do |m|
      sitemap_task = "require 'blacklight-sitemap'\nRake::BlacklightSitemapTask.new"
      rakefile = File.read('Rakefile')
      if rakefile.scan(sitemap_task).empty?
        rakefile << "\n" << sitemap_task
        File.open('Rakefile', 'w'){|f| f.puts rakefile}
      end      
    end
  end

  protected

  def banner
    %{Usage: #{$0} #{spec.name}\nCopies OpenURL.js public/javascripts/}
  end

end
