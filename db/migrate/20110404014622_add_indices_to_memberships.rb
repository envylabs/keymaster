class AddIndicesToMemberships < ActiveRecord::Migration
  def self.up
    add_index :memberships, :project_id
    add_index :memberships, :user_id
  end

  def self.down
    remove_index :memberships, :user_id
    remove_index :memberships, :project_id
  end
end
