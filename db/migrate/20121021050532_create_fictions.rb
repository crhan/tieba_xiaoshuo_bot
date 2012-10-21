# -*- encoding : utf-8 -*-
class CreateFictions < ActiveRecord::Migration
  def change
    create_table :fictions do |t|
      t.string :name
      t.string :encoded_url

      t.timestamps
    end
  end
end
