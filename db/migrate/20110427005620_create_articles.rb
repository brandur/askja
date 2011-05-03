class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string   :title
      t.string   :content
      t.string   :permalink
      t.string   :tinylink
      t.string   :location
      t.datetime :published_at
      t.datetime :last_updated_at
      t.integer  :views, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
