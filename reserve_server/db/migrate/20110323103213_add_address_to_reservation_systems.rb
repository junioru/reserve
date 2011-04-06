class AddAddressToReservationSystems < ActiveRecord::Migration
  def self.up
    add_column :reservation_systems, :address, :string
  end

  def self.down
    remove_column :reservation_systems, :address
  end
end
