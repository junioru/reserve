class AddCancellationToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :cancellation, :boolean, :default => true, :null => false
  end

  def self.down
     remove_column :resources, :cancellation
  end
end
