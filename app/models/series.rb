class Series < ActiveRecord::Base
  has_many :articles, :order => :published_at

  validates_presence_of :title, :content, :permalink, :tinylink
  validates_uniqueness_of :permalink, :tinylink

  scope :active, -> { joins(:articles).where('series_id IN (SELECT DISTINCT(series_id) FROM articles WHERE published_at < ?)', Time.now) }
  
  def content_html
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, 
      :fenced_code_blocks => true, :hard_wrap => true)
    html = renderer.render(content)

    # Redcarpet now allows a new renderer to be defined. This would be better.
    html = html.gsub /<code class="(\w+)">/, %q|<code class="language-\1">|
  end

  def to_param
    permalink
  end
end
