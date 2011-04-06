class CreateReservations < ActiveRecord::Migration
  def self.up
   create_table :reservations do |t|
      t.integer :user_id
      t.integer :resource_id
      t.datetime  :startDate
      t.datetime  :endDate
      t.string  :recurring
      t.text  :description

      t.timestamps
    end
    add_index :reservations, :user_id
    add_index :reservations, :resource_id 
    add_index :reservations, :startDate
    add_index :reservations, :endDate
  end

  def self.down
    drop_table :reservations
  end
end
