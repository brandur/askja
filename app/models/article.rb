class Article < ActiveRecord::Base
  has_and_belongs_to_many :related_articles, :class_name => 'Article', 
    :join_table => :article_similarities, 
    :foreign_key => :article_id, 
    :association_foreign_key => :similar_article_id

  validates_presence_of :title, :content, :permalink, :tinylink, :location, :published_at, :last_updated_at
  validates_uniqueness_of :permalink, :tinylink

  #default_scope :order => 'published_at DESC'
  scope :published, -> { where('published_at < ?', Time.now).order('published_at DESC') }
  scope :top, where('views > 0').order('views DESC')

  def content_html
    html = Redcarpet.new(content, :fenced_code, :hard_wrap, :smart).to_html
    html = html.gsub /<code class="(\w+)">/, %q|<code class="language-\1">|
  end

  # Content minus code blocks
  def content_text
    content.gsub(/^\s*```.*^\s*```\s*$/m, '')
  end

  def to_param
    permalink
  end
end
