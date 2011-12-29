desc 'Initialize a new Askja environment'
task :init do
  `mkdir -p #{File.dirname(__FILE__)}/content/articles`
  `mkdir -p #{File.dirname(__FILE__)}/content/images`
  `mkdir -p #{File.dirname(__FILE__)}/content/series`
  `ln -sf #{File.dirname(__FILE__)}/content/images #{File.dirname(__FILE__)}/public/images/articles`
  $stdout.puts 'Initialized Askja content'
end

