class CreateReservationFloorplans < ActiveRecord::Migration
  def self.up
    create_table :reservation_floorplans do |t|
      t.string :caption
      t.integer :reservation_system_id

      t.timestamps
    end
  end

  def self.down
    drop_table :reservation_floorplans
  end
end
