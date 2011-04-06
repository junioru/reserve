class AddImagemapToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :html, :string
    add_column :resources, :reservation_floorplan_id, :integer

  end

  def self.down
    remove_column :resources, :reservation_floorplan_id
    remove_column :resources, :html
  end
end
