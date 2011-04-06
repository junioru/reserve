# == Schema Information
# Schema version: 20110227141112
#
# Table name: reservations
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  resource_id :integer(4)
#  startDate   :datetime
#  endDate     :datetime
#  recurring   :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  delta       :boolean(1)      default(TRUE), not null
#  status      :string(255)     default("confirmed")
#

class Reservation < ActiveRecord::Base
  attr_accessible :startDate, :endDate, :recurring, :description, :resource_id

  belongs_to :user
  belongs_to :resource

  default_scope :order => 'reservations.startDate DESC'

  validates :user_id, :presence => true
  validates :resource_id, :presence => true
  validates :startDate, :presence => true
  validates :endDate, :presence => true

  define_index do
    indexes resource(:name), :as => :resource_name
    indexes status
    indexes recurring
  
    has user_id, resource_id
    has "UNIX_TIMESTAMP(DATE(startDate))", :type => :integer, :as => :startDate
    has "UNIX_TIMESTAMP(DATE(endDate))", :type => :integer, :as => :endDate
    has "HOUR(startDate)*3600 + MINUTE(startDate)*60", :type => :integer, :as => :startTime
    has "HOUR(endDate)*3600 + MINUTE(endDate)*60", :type => :integer, :as => :endTime
    set_property :delta => true
  end
end
