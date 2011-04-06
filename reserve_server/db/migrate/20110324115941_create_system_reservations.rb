class CreateSystemReservations < ActiveRecord::Migration
  def self.up
    create_table :system_reservations do |t|
      t.integer :reservation_system_id
      t.datetime :startDate
      t.datetime :endDate
      t.string :recurring
      t.text :description

      t.timestamps
    end
  end

  def self.down
    drop_table :system_reservations
  end
end
