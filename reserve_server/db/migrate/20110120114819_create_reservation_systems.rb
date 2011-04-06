class CreateReservationSystems < ActiveRecord::Migration
  def self.up
    create_table :reservation_systems do |t|
      t.integer :user_id
      t.string :category
      t.string :name
      t.string :location
      t.text    :description
      t.timestamps
    end
    add_index :reservation_systems, :user_id
    add_index :reservation_systems, :category
    add_index :reservation_systems, :location
  end

  def self.down
    drop_table :reservation_systems
  end
end
