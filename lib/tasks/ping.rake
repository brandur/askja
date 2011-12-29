desc 'Ping major search engines to indicate that our sitemap has been updated'
task :ping => :environment do
  if !App.url
    $stderr.puts "\t[error] Missing config key 'url'."
    exit 1
  end

  sitemap = App.url + Rails.application.routes.url_helpers.sitemap_path(:format => :xml)
  [ "http://www.google.com/webmasters/sitemaps/ping?sitemap=",
    "http://www.bing.com/webmaster/ping.aspx?siteMap=" ,
    "http://search.yahooapis.com/SiteExplorerService/V1/updateNotification?appid=YahooDemo&url="
  ].each do |url|
    $stdout.puts "Pinging #{url}#{sitemap}"
    puts `curl #{url}#{sitemap}`
  end
end
