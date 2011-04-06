module ReservationHelper

def rating_ballot(resource_id)
    if @rating = current_user.ratings.find_by_resource_id(resource_id)
        @rating
    else
        current_user.ratings.new
    end
end

def current_user_rating(resource_id)
    if @rating = current_user.ratings.find_by_resource_id(resource_id)
        @rating.value
    else
        "N/A"
    end
end

end
