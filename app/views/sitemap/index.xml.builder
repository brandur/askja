xml.instruct! :xml, :version=>'1.0'
xml.tag! 'urlset', 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  @pages.each do |page|
    xml.tag! 'url' do
      xml.tag! 'loc',        page.location
      xml.tag! 'lastmod',    page.last_modified_at.iso8601
      xml.tag! 'changefreq', page.change_frequency
      #xml.tag! 'priority',   '0.5'
    end
  end
end
