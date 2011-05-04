class SeriesController < ApplicationController

  caches_page :show

  def show
    @series = Series.active.find_by_permalink(params[:permalink], :include => :articles)
    raise ActiveRecord::RecordNotFound unless @series

    respond_to do |format|
      format.atom
      format.json { render :json => @series }
      format.html
    end
  end

  def redirect_tinylink
    @series = Series.active.find_by_tinylink(params[:tinylink])
    raise ActiveRecord::RecordNotFound unless @series
    redirect_to series_path(@series)
  end

  # Internal

  def expire_for(series)
    expire_page "/series/#{series.permalink}"
    article_cache_controller = ArticlesController.new
    series.articles.each do |article|
      article_cache_controller.expire_for(article)
    end
  end

  def expire_lists
  end

end
