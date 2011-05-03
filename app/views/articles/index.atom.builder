atom_feed do |feed|
  feed.title(APP_CONFIG['title'])
  feed.updated(@articles.first.published_at)

  for article in @articles
    feed.entry(
      article, 
      :id        => "tag:mutelight.org,#{article.published_at.strftime('%F')}:#{article_path(article)}.html", 
      :published => article.published_at, 
      :updated   => article.published_at
    ) do |entry|
      entry.title(article.title)
      entry.content(article.content_html, :type => 'html')

      entry.author do |author|
        author.name('Brandur Leach')
        author.uri('http://brandur.org')
      end
    end
  end
end

