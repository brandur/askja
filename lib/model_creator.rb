class ModelCreator

  def initialize(name)
    @name = name
  end

  def calc_components(title)
    [ title.titleize, title.parameterize('-') ]
  end

  def create(meta, permalink)
    path = "#{File.dirname(__FILE__)}/../content/#{@name}/"
    md  = File.expand_path("#{path}#{permalink}.md")
    yml = File.expand_path("#{path}#{permalink}.yml")
    File.open(md,  'w') {|f| f.write('')}
    File.open(yml, 'w') {|f| YAML.dump(meta, f)}
    [ yml, md ]
  end

end

