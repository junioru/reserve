class AddStatusToReservations < ActiveRecord::Migration
  def self.up
    add_column :reservations, :status, :string, :default => 'Confirmed'
  end

  def self.down
    remove_column :reservations, :status
  end
end
