# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)
require 'rake'
require 'highline/import'

Askja::Application.load_tasks

namespace :create do
  desc 'Creates a new article'
  task :article do
    def calc_path(title)
      slug = title.parameterize('-')
      path = "#{File.dirname(__FILE__)}/content/articles/"
      [ title.titleize, slug, "#{path}#{slug}.md", "#{path}#{slug}.yml" ]
    end

    if !ENV['title']
      $stderr.puts "\t[error] Missing title argument.\n\tusage: rake create:article title='article title'"
      exit 1
    end

    title, slug, md, yml = calc_path(ENV['title'])

    meta = {
      'title'        => title, 
      'permalink'    => slug, 
      'tinylink'     => title.split(/ /).first.strip.downcase.gsub(/[^A-Za-z0-9]/, ''),
      'published_at' => Time.now.strftime("%B %d, %Y %k:%M"), 
      'location'     => 'Calgary'
    }

    File.open(md,  'w') {|f| f.write('')}
    File.open(yml, 'w') {|f| YAML.dump(meta, f)}
    $stdout.puts "\t[ok] Edit #{md}"
    `ln -f -s #{md} current_article`
    `ln -f -s #{yml} current_article.yml`
  end
end

desc 'Initialize a new Askja environment'
task :init do
  `mkdir -p #{File.dirname(__FILE__)}/content/articles`
  `mkdir -p #{File.dirname(__FILE__)}/content/images`
  `ln -sf #{File.dirname(__FILE__)}/content/images #{File.dirname(__FILE__)}/public/images/articles`
  $stdout.puts 'Initialized Askja content'
end

desc 'Updates all entities'
task :update => [ 'update:articles', 'update:related' ]

namespace :update do
  desc 'Update articles from *.yml files in content/articles/, use path= for a specific article'
  task :articles => :environment do
    paths = unless ENV['path']
      Dir["#{File.dirname(__FILE__)}/content/articles/**/*.yml"]
    else
      [ENV['path']]
    end
    is_forced = to_bool(ENV['force'])
    $stdout.puts 'forcing update' if is_forced
    num_articles_updated = ArticlesController.new.update(paths.sort, is_forced)
    $stdout.puts "Updated #{num_articles_updated} article(s)"
  end

  desc 'Update all articles with their related articles (options num= and verbose=)'
  task :related => :environment do
    is_verbose = to_bool(ENV['verbose'])
    num_related = (ENV['num'] || 3).to_i
    lsi = Classifier::LSI.new
    articles = Article.published.all
    articles.each do |article|
      lsi.add_item(article) {|x| article.content_text}
    end
    articles.each do |article|
      article.related_articles.clear
      $stdout.puts "Articles related to '#{article.title}'" if is_verbose
      lsi.find_related(article.content_text, num_related + 1).find_all{|r| r != article}.take(num_related).each do |related_article|
        $stdout.puts "    * #{related_article.title}" if is_verbose
        article.related_articles << related_article
      end
      article.save!
      $stdout.puts '' if is_verbose
    end
    $stdout.puts "Updated related articles for #{articles.count} article(s)"
  end

  task :top => :environment do
    if APP_CONFIG['analytics_id'].blank?
      $stderr.puts "Config option 'analytics_id' must be set to fetch top articles"
      exit
    end
    is_verbose = to_bool(ENV['verbose'])
    username = ask('Username: ')
    password = ask('Password: ') {|q| q.echo = false}
    Garb::Session.login(username, password)
    profile = Garb::Management::Profile.all.detect {|p| p.web_property_id == APP_CONFIG['analytics_id']}
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

