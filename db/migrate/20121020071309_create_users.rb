class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :account
      t.integer :send_count
      t.boolean :active

      t.timestamps
    end
  end
end
