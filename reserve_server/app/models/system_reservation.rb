class SystemReservation < ActiveRecord::Base
  attr_accessible :startDate, :endDate, :recurring, :description, :reservation_system_id

  belongs_to :reservation_system


  validates :startDate, :presence => true
  validates :endDate, :presence => true
  validates :reservation_system_id, :presence => true

  

end
