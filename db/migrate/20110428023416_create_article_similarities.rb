class CreateArticleSimilarities < ActiveRecord::Migration
  def self.up
    create_table :article_similarities, :id => false do |t|
      t.integer :article_id,         :null => false
      t.integer :similar_article_id, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :article_similarities
  end
end
