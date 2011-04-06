class AddPhotoToResources < ActiveRecord::Migration
  def self.up
    add_column :resources, :photo_file_name, :string
    add_column :resources, :photo_content_type, :string
    add_column :resources, :photo_file_size, :integer
    add_column :resources, :photo_updated_at, :datetime
  end

  def self.down
    remove_column :resources, :photo_file_name
    remove_column :resources, :photo_content_type
    remove_column :resources, :photo_file_size
    remove_column :resources, :photo_updated_at
  end
end