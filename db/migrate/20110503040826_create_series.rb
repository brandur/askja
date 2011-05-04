class CreateSeries < ActiveRecord::Migration
  def self.up
    create_table :series do |t|
      t.string   :title
      t.string   :content
      t.string   :permalink
      t.string   :tinylink
      t.datetime :last_updated_at

      t.timestamps
    end

    add_column :articles, :series_id, :integer
  end

  def self.down
    remove_column :articles, :series_id
    drop_table :series
  end
end
