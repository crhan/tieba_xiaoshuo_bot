# -*- encoding : utf-8 -*-
class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.integer :thread_id
      t.references :fiction
      t.string :title

      t.timestamps
    end
    add_index :chapters, :fiction_id
  end
end
