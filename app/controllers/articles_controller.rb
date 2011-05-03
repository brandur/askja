class ArticlesController < ApplicationController

  caches_page :archive, :index, :show

  def archive
    @articles = Article.published.all.group_by{ |p| p.published_at.year }.sort.reverse

    respond_to do |format|
      format.json { render :json => @articles }
      format.html { render :layout => 'application' }
    end
  end

  def index
    @articles = Article.published.limit(10)
    @top_articles = Article.top.limit(5) if request.format.html?

    respond_to do |format|
      format.atom
      format.json { render :json => @articles }
      format.html { render :layout => 'application' }
    end
  end

  def show
    @article = Article.published.find_by_permalink(params[:permalink])
    raise ActiveRecord::RecordNotFound unless @article

    # Use LSI related articles if we have them, otherwise just a few of the 
    # newest
    if request.format.html?
      @other_articles = @article.related_articles.limit(3)
      @have_related   = @other_articles.count > 0
      @other_articles = Article.published.limit(3) unless @have_related
    end

    respond_to do |format|
      format.json { render :json => @article }
      format.html
    end
  end

  def redirect_tinylink
    @article = Article.published.find_by_tinylink(params[:tinylink])
    raise ActiveRecord::RecordNotFound unless @article
    redirect_to article_path(@article)
  end

  # Designed to be called by Rake to load articles into the system
  def update(paths, is_forced = false)
    num_articles_updated = 0
    paths.each do |path|
      article = Article.new(YAML.load_file(path))
      existing_article = Article.find_by_permalink(article.permalink)
      article = if existing_article
        # Don't perform an update if the file hasn't been modified
        next if existing_article.last_updated_at == content_last_updated(path) && !is_forced

        article.content = read_content(path) unless article.content
        existing_article.attributes = article.attributes
        existing_article
      else
        article.content = read_content(path) unless article.content
        article
      end
      article.last_updated_at = content_last_updated(path)
      article.save!
      $stdout.puts "\t[ok] Saved #{path}"
      expire_page "/articles/#{article.permalink}"
      num_articles_updated += 1
    end
    if num_articles_updated > 0
      expire_page '/'
      expire_page '/archive'
      expire_page '/articles'
    end
    num_articles_updated
  end

  private

  def content_last_updated(path)
    paths = [path]
    paths.push(content_path(path)) if File.exists?(content_path(path))
    paths.map{ |p| File::mtime(p) }.max
  end

  def content_path(path)
    path.gsub /\.ya?ml$/, '.md'
  end

  def read_content(path)
    File.open(content_path(path), 'rb').read
  end

end
