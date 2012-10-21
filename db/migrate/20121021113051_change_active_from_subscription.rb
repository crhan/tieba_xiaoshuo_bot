# -*- encoding : utf-8 -*-
class ChangeActiveFromSubscription < ActiveRecord::Migration
  def up
    change_column :subscriptions, :active, :boolean, :default => true
  end

  def down
    change_column :subscriptions, :active, :boolean, :default => nil
  end
end
