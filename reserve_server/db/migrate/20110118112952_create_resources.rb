class CreateResources < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.integer :reservation_system_id
      t.string :name
      t.integer :capacity
      t.text :description
      t.string :startTime
      t.string :endTime
    

      t.timestamps
    end
    add_index :resources, :reservation_system_id
    add_index :resources, :capacity
    add_index :resources, :startTime
    add_index :resources, :endTime
  end

  def self.down
    drop_table :resources
  end
end
