class AddLoginIndexToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :login, :unique => true
  end

  def self.down
    remove_index :users, :login
  end
end
