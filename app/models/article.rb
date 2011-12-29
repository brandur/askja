class Article < ActiveRecord::Base
  belongs_to :series

  validates_presence_of :title, :content, :permalink, :tinylink, :location, :published_at, :last_updated_at
  validates_uniqueness_of :permalink, :tinylink

  scope :published, -> { where('published_at < ?', Time.now).order('published_at DESC') }
  scope :top, where('views > 0').order('views DESC')

  def content_html
    renderer = Redcarpet::Markdown.new(Redcarpet::Render::HTML, 
      :fenced_code_blocks => true, :hard_wrap => true)
    html = renderer.render(content)

    # Redcarpet now allows a new renderer to be defined. This would be better.
    html = html.gsub /<code class="(\w+)">/, %q|<code class="language-\1">|
  end

  # Content minus code blocks
  def content_text
    content.gsub(/^\s*```.*^\s*```\s*$/m, '')
  end

  def series_permalink=(s)
    self.series = Series.find_by_permalink(s)
  end

  def series_position
    series.articles.where('published_at < ?', published_at).count + 1
  end

  def to_param
    permalink
  end
end
