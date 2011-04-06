class AddAllowCancelToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :allowcancel, :boolean , :default => true
  end

  def self.down
    remove_column :resources, :allowcancel
  end
end
