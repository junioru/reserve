class Rating < ActiveRecord::Base

attr_accessible :value
belongs_to :resource
belongs_to :user
end
