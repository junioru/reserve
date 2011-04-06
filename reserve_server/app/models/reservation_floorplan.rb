# == Schema Information
# Schema version: 20110304210908
#
# Table name: reservation_floorplans
#
#  id                     :integer(4)      not null, primary key
#  caption                :string(255)
#  reservation_system_id  :integer(4)
#  created_at             :datetime
#  updated_at             :datetime
#  floorplan_file_name    :string(255)
#  floorplan_content_type :string(255)
#  floorplan_file_size    :integer(4)
#  floorplan_updated_at   :datetime
#

class ReservationFloorplan < ActiveRecord::Base
  attr_accessible :floorplan, :caption
  belongs_to :reservation_system
  has_many :resources

  has_attached_file :floorplan, :styles => { :medium => "320x320>", :thumb => "64x64>" , :large => "800x800>" }
  

  validates_attachment_presence :floorplan
  validates_attachment_size :floorplan, :less_than => 2.megabytes
  validates_presence_of :caption
end
