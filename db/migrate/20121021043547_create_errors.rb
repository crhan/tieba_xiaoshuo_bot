# -*- encoding : utf-8 -*-
class CreateErrors < ActiveRecord::Migration
  def change
    create_table :errors do |t|
      t.string :exception
      t.string :message
      t.text :backtrace

      t.timestamps
    end
  end
end
