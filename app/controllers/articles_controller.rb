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
    @article = Article.published.find_by_permalink!(params[:permalink])

    if request.format.html?
      @other_articles = Article.published.limit(3)
    end

    respond_to do |format|
      format.json { render :json => @article }
      format.html
    end
  end

  def redirect_tinylink
    @article = Article.published.find_by_tinylink!(params[:tinylink])
    redirect_to article_path(@article)
  end

  # Internal

  def expire_for(article)
    expire_page_all_formats "/articles/#{article.permalink}"
    expire_page_all_formats "/series/#{article.series}" if article.series
  end

  def expire_lists
    expire_page_all_formats '/'
    expire_page_all_formats '/archive'
    expire_page_all_formats '/articles'
    expire_page_all_formats '/atom'
  end

end

