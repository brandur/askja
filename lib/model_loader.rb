class ModelLoader

  def initialize(model_class, cache_controller)
    @model_class      = model_class
    @cache_controller = cache_controller
  end

  def load(paths, is_forced = false)
    saved_models = []
    paths.sort.each do |path|
      model = @model_class.new(YAML.load_file(path))
      existing_model = @model_class.find_by_permalink(model.permalink)
      model = if existing_model
        # Don't perform an update if the file hasn't been modified
        next if existing_model.last_updated_at == content_last_updated(path) && !is_forced

        model.content = read_content(path) unless model.content
        existing_model.attributes = model.attributes
        existing_model
      else
        model.content = read_content(path) unless model.content
        model
      end
      model.last_updated_at = content_last_updated(path)
      model.save!
      @cache_controller.expire_for(model)
      saved_models << model
      yield model
    end
    @cache_controller.expire_lists if saved_models.count > 0
    saved_models
  end

  private

  def content_last_updated(path)
    paths = [path]
    paths.push(content_path(path)) if File.exists?(content_path(path))
    paths.map{|p| File::mtime(p)}.max
  end

  def content_path(path)
    path.gsub /\.ya?ml$/, '.md'
  end

  def read_content(path)
    File.open(content_path(path), 'rb').read
  end

end
