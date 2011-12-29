desc 'Updates all entities'
task :update => [ 'update:series', 'update:articles' ]

namespace :update do
  # @todo: abstract this task
  desc 'Update articles from *.yml files in content/articles/, use path= for a specific article'
  task :articles => :environment do
    update_model('articles', Article, ArticlesController.new)
  end

  desc 'Update series from *.yml files in content/series/, use path= for a specific series'
  task :series => :environment do
    update_model('series', Series, SeriesController.new)
  end

  task :top => :environment do
    if App.analytics_id.blank?
      $stderr.puts "Config option 'analytics_id' must be set to fetch top articles"
      exit
    end
    is_verbose = to_bool(ENV['verbose'])
    username = ask('Username: ')
    password = ask('Password: ') {|q| q.echo = false}
    Garb::Session.login(username, password)
    profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == App.analytics_id}
    results = TopArticles.results(profile, 
      :filters => {:page_path.contains => '^/articles/*'}, 
      :sort => :pageviews.desc, 
      :start_date => 5.years.ago, 
      :end_date => Time.now
    )
    permalinks = Set.new
    Article.transaction do
      Article.connection.execute('UPDATE articles SET views = 0')
      results.each do |result|
        permalink = result.page_path.gsub(/^\/articles\/(.*?)(\.html)?$/, '\1')
        article = Article.find_by_permalink(permalink)
        next unless article
        article.views += result.pageviews.to_i
        article.save
        permalinks.add(permalink)
        $stdout.puts "    * #{article.title} --> #{result.pageviews} view(s)" if is_verbose
      end
    end
    $stdout.puts "Ranked top #{permalinks.count} article(s)"
  end
end

class TopArticles
  extend Garb::Model
  dimensions :page_path
  metrics :pageviews
end

def to_bool(str)
  [ '1', 'true', 'y'].include?(str)
end

def update_model(name, klass, cache_controller)
  paths = unless ENV['path']
    Dir["#{File.dirname(__FILE__)}/content/#{name}/**/*.yml"]
  else
    [ENV['path']]
  end
  is_forced = to_bool(ENV['force'])
  $stdout.puts 'Forcing update' if is_forced
  updated = ModelLoader.new(klass, cache_controller).load(paths, is_forced) do |model|
    $stdout.puts "\t[ok] Saved '#{model.title}'"
  end
  $stdout.puts "Updated #{updated.count} #{name}"
end
