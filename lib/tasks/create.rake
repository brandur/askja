namespace :create do
  desc 'Creates a new article'
  task :article do
    yml, md = create_model('articles') do |title, permalink|
      {
        'title'        => title, 
        'permalink'    => permalink, 
        'tinylink'     => title.split(/ /).first.strip.downcase.gsub(/[^A-Za-z0-9]/, ''),
        'published_at' => Time.now.strftime("%B %d, %Y %k:%M"), 
        'location'     => 'Calgary', 
      }
    end
    `ln -f -s #{md} current_article`
    `ln -f -s #{yml} current_article.yml`
  end

  desc 'Creates a new series'
  task :series do
    create_model('series') do |title, permalink|
      {
        'title'     => title, 
        'permalink' => permalink, 
        'tinylink'  => title.split(/ /).first.strip.downcase.gsub(/[^A-Za-z0-9]/, ''),
      }
    end
  end
end

def create_model(name)
  if !ENV['title']
    $stderr.puts "\t[error] Missing title argument.\n\tUsage: rake create:#{name} title='title'"
    exit 1
  end

  creator = ModelCreator.new(name)
  title, permalink = creator.calc_components(ENV['title'])

  meta = yield title, permalink

  yml, md = creator.create(meta, permalink)
  $stdout.puts "\t[ok] Edit #{md}"
  [ yml, md ]
end

