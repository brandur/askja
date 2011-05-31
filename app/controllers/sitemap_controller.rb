class SitemapController < ApplicationController
  def index
    base_url = request.protocol + request.host_with_port
    latest_article = Article.published.first
    @pages = []

    @pages << Page.new(
      :location         => base_url,
      :last_modified_at => [latest_article.published_at, latest_article.updated_at].find_all{|a| !a.nil?}.max,
      :change_frequency => 'daily'
    )
    @pages << Page.new(
      :location         => base_url + archive_path,
      :last_modified_at => [latest_article.published_at, latest_article.updated_at].find_all{|a| !a.nil?}.max,
      :change_frequency => 'daily'
    )

    Article.published.each do |article|
      @pages << Page.new(
        :location         => base_url + article_path(article),
        :last_modified_at => [article.published_at, article.updated_at].find_all{|a| !a.nil?}.max,
        :change_frequency => 'weekly'
      )
    end
    Series.active.each do |series|
      articles = series.articles
      last_modified_at = if articles && articles.last.published_at > series.updated_at
        articles.last.published_at
      else
        series.updated_at
      end
      @pages << Page.new(
        :location         => base_url + series_path(series),
        :last_modified_at => last_modified_at, 
        :change_frequency => 'daily'
      )
    end

    if stale?(:etag => latest_article, :last_modified => latest_article.updated_at.utc)
      respond_to do |format|
        format.xml  { render :layout => nil }
      end
    end
  end

  private

  class Page
    attr_accessor :location, :last_modified_at, :change_frequency

    def initialize(params)
      self.location         = params[:location]
      self.last_modified_at = params[:last_modified_at]
      self.change_frequency = params[:change_frequency]
    end
  end
end
