# -*- encoding : utf-8 -*-
class CreateFeedbacks < ActiveRecord::Migration
  def change
    create_table :feedbacks do |t|
      t.references :user
      t.text :msg

      t.timestamps
    end
  end
end
