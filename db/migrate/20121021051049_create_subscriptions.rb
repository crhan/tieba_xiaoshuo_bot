# -*- encoding : utf-8 -*-
class CreateSubscriptions < ActiveRecord::Migration
  def change
    create_table :subscriptions do |t|
      t.references :fiction
      t.references :user
      t.references :chapter
      t.boolean :active, :default => false

      t.timestamps
    end
    add_index :subscriptions, :fiction_id
    add_index :subscriptions, :user_id
    add_index :subscriptions, :chapter_id
  end
end
