require 'blacklight-sitemap'
Rake::BlacklightSitemapTask.new do |sm|
  # below are configuration options with their default values shown.

  # FIXME: you'll definitely want to change the resource_url value
  # base url for resources
  # sm.resource_url = 'http://localhost:3000/catalog'

  # FIXME: you'll definitely want to change the public_url value
  # base url for public directory of application where sitemaps will be placed
  # sm.public_url = 'http://localhost:3000'

  # If you have IIIF manifests you want to expose via a sitemap set this to a
  # IIIF URL template.
  # sm.iiif_manifest_template = false # default
  # sm.iiif_manifest_template = "https://d.lib.ncsu.edu/collections/catalog/%{identifier}/manifest.json"
  # sm.iiif_presentation_version = '2.1'

  # base filename given to generated sitemap files
  # sm.base_filename = 'blacklight'

  # Is the gzip commandline tool available? Then why not gzip up your sitemaps to
  # save bandwidth?
  # sm.gzip = false

  # for changefreq see http://sitemaps.org/protocol.php#changefreqdef
  # valid values are: always, hourly, daily, weekly, monthly, yearly, never
  # sm.changefreq = nil # nil won't display a changefreq element

  # sitemaps can contain up to 50000 locations, but also must not be more than
  # 10 MB in size. Using the max value you can control the size of your files.
  # sm.max = 50000

  # Solr field used to retrieve from a document the value for the lastmod element for a url
  # sm.lastmod_field = 'timestamp'

  # Solr field used to retrieve from a document the value for the priority element for a url
  # sm.priority_field = nil

  # Solr query sort parameter
  # sm.sort = '_docid_ asc'

  # Solr request handler. This can be useful when your Solr configuration already has
  # a filter query appended.
  # sm.qt = 'standard'
end
