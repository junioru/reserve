class AddMinDurationToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :min_duration, :integer
  end

  def self.down
    remove_column :resources, :min_duration
  end
end
