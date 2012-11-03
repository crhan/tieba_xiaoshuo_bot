# -*- encoding : utf-8 -*-
class AddDefaultValueToSubscription < ActiveRecord::Migration
  def up
    change_column :subscriptions, :active, :boolean, :default => false
  end
  def down
    change_column :subscriptions, :active, :boolean, :default => nil
  end
end
