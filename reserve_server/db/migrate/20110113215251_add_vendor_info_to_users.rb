class AddVendorInfoToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :user_type, :string, :default=>"personal"
    add_column :users, :business_name, :string
    add_column :users, :business_category, :string
  end

  def self.down
    remove_column :users, :business_category
    remove_column :users, :business_name
    remove_column :users, :user_type
  end
end
