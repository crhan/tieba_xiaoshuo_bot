class AddActiveToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :active, :boolean, :default => true
  end
end
