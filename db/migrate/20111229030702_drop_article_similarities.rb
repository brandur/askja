class DropArticleSimilarities < ActiveRecord::Migration
  def change
    drop_table :article_similarities
  end
end
