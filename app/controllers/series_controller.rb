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

  # Designed to be called by Rake to load series into the system
  def update(paths, is_forced = false)
    num_series_updated = 0
    paths.each do |path|
      series = Series.new(YAML.load_file(path))
      existing_series = Series.find_by_permalink(series.permalink)
      series = if existing_series
        # Don't perform an update if the file hasn't been modified
        next if existing_series.last_updated_at == content_last_updated(path) && !is_forced

        series.content = read_content(path) unless series.content
        existing_series.attributes = series.attributes
        existing_series
      else
        series.content = read_content(path) unless series.content
        series
      end
      series.last_updated_at = content_last_updated(path)
      series.save!
      $stdout.puts "\t[ok] Saved #{path}"
      expire_page "/series/#{series.permalink}"
      num_series_updated += 1
    end
    if num_series_updated > 0
      expire_page '/'
      expire_page '/archive'
      expire_page '/series'
    end
    num_series_updated
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
