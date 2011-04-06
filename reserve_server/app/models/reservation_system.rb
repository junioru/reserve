# == Schema Information
# Schema version: 20110227141112
#
# Table name: reservation_systems
#
#  id          :integer(4)      not null, primary key
#  user_id     :integer(4)
#  category    :string(255)
#  name        :string(255)
#  location    :string(255)
#  description :text
#  created_at  :datetime
#  updated_at  :datetime
#  delta       :boolean(1)      default(TRUE), not null
#

class ReservationSystem < ActiveRecord::Base
  attr_accessible :category, :name, :location, :description, :address

  belongs_to :user
  has_many :resources, :dependent => :destroy
  has_many :reservation_floorplans, :dependent => :destroy
  has_many :system_reservations, :dependent => :destroy

  validates :name,  :presence => true,
                    :length => {:within => 3 .. 50 },
                    :uniqueness => true
  validates :address,  :presence => true 
  validates :category, :presence =>true

  define_index do
    indexes name, :sortable => true
    indexes resources(:name), :as => :resource_name
    indexes resources(:description), :as => :resource_description
    indexes category
    indexes description
    indexes address
   
    has location, user_id
    has resources(:capacity), :as => :resource_capacity 
    has resources(:startTime),:as => :resource_startTime
    has resources(:endTime), :as => :resource_endTime
    set_property :delta => true
  end

  def rating_count
    @total=0
    self.resources.each do |resource|
      @total += resource.ratings.size
    end
    @total
  end

  def average_rating
    @value = 0
    self.resources.each do |resource|
        resource.ratings.each do |rating|
          @value = @value + rating.value
        end
    end
    @value.to_f / rating_count.to_f
  end

end
