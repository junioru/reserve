class AddDeltas < ActiveRecord::Migration
  def self.up
    add_column :reservations, :delta, :boolean, :default => true, :null => false
    add_column :reservation_systems, :delta, :boolean, :default => true, :null => false
    add_column :resources, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :reservations, :delta
    remove_column :reservation_systems, :delta
    remove_column :resources, :delta
  end
end
