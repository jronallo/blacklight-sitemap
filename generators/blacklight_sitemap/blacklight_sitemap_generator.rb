class BlacklightSitemapGenerator < Rails::Generator::Base
  def initialize(*runtime_args)
    super
  end

  def manifest
    record do |m|
      sitemap_task = <<EOF 
require 'blacklight-sitemap'
Rake::BlacklightSitemapTask.new do |sm|
  # sm.url = 'http://localhost:3000'
  # sm.gzip = false
  # sm.changefreq = '' #valid values are: 
  # sm.ceiling = 50000
  # sm.lastmod_field = 'timestamp'
end
EOF
      rakefile = File.read('Rakefile')
      if rakefile.scan('Rake::BlacklightSitemapTask.new').empty?
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
