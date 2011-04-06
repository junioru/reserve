class AddUserUnqiuenessIndex < ActiveRecord::Migration
  def self.up
    add_index :users, :email, :unique =>true
    add_index :users, :mobile_number, :unique => true
  end

  def self.down
    remove_index :users, :email
    remove_index :users, :mobile_number
  end
end
