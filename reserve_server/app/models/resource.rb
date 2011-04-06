# == Schema Information
# Schema version: 20110304210908
#
# Table name: resources
#
#  id                       :integer(4)      not null, primary key
#  reservation_system_id    :integer(4)
#  name                     :string(255)
#  capacity                 :integer(4)
#  description              :text
#  startTime                :string(255)
#  endTime                  :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  photo_file_name          :string(255)
#  photo_content_type       :string(255)
#  photo_file_size          :integer(4)
#  photo_updated_at         :datetime
#  min_duration             :integer(4)
#  delta                    :boolean(1)      default(TRUE), not null
#  cancellation             :boolean(1)      default(TRUE), not null
#  html                     :string(255)
#  reservation_floorplan_id :integer(4)
#  allowcancel              :boolean(1)      default(TRUE)
#

class Resource < ActiveRecord::Base
  attr_accessible :name,:capacity, :description, :startTime, :endTime, :photo, :min_duration, :allowcancel, :html, :reservation_floorplan_id

  belongs_to :reservation_system
  has_many  :reservations
  belongs_to  :reservation_floorplan
  has_many :ratings
  has_many :raters, :through => :ratings, :source => :users
  validates :reservation_system_id, :presence => true
  validates :name, :presence => true
  validates :capacity, :presence => true
  validates :startTime, :presence => true
  validates :endTime , :presence => true
  
  validates_attachment_size :photo, :less_than => 2.megabytes

  before_save :convert_to_sec

  #Paperclip
  has_attached_file :photo, :styles => { :medium => "320x320>", :thumb => "64x64>" , :large => "800x800>" }

  #Thinking Sphinx
  define_index do
    indexes name, :sortable=> true
    indexes description
    indexes reservation_system(:name), :as => :system_name
    indexes reservation_system(:category), :as => :system_category
    
    has reservation_system_id, capacity, min_duration
    has startTime, :type => :integer, :as => :startTime_i
    has endTime, :type => :integer, :as => :endTime_i
    set_property :delta => true
  end

  def convert_to_sec
    self.startTime = time_to_seconds(self.startTime)
    self.endTime = time_to_seconds(self.endTime)
    if self.min_duration.blank?
      self.min_duration = 60
    end
    self.min_duration *= 60
  end

  def time_to_seconds(time)
    time_arr = time.split(':')
    return  (time_arr[0].to_i*3600 + time_arr[1].to_i*60).to_s
  end

  def average_rating
    @value = 0
    self.ratings.each do |rating|
        @value = @value + rating.value
    end
    @total = self.ratings.size
    @value.to_f / @total.to_f
  end

end
