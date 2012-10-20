class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :account
      t.integer :send_count, :default => 0
      t.boolean :active, :default => true

      t.timestamps
    end
  end
end
