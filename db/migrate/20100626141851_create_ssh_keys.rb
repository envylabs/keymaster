class CreateSshKeys < ActiveRecord::Migration
  def self.up
    create_table :ssh_keys do |t|
      t.integer :user_id, :null => false
      t.text :public_key, :null => false
      t.timestamps
    end
    add_index :ssh_keys, :user_id

    say_with_time("Migrating SSH keys") do
      User.find_each do |user|
        user.ssh_keys.create!(:public_key => user.public_ssh_key)
      end
    end

    remove_column :users, :public_ssh_key
  end

  def self.down
    add_column :users, :public_ssh_key, :text
    User.reset_column_information

    say_with_time("Migrating SSH keys") do
      User.find_each do |user|
        say "[Warning] Only keeping first key for #{user.login}" if user.ssh_keys.count > 1
        user.update_attributes!(:public_ssh_key => user.ssh_keys.first.public_key)
      end
    end

    remove_index :ssh_keys, :user_id
    drop_table :ssh_keys
  end
end
