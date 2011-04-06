class PagesController < ApplicationController
  before_filter :authenticate
  include ActionView::Helpers::AssetTagHelper
  def controller; self end;

  def index
    @title = "Category List"
  end

  def searchform
    @title = "Search For Reservations"
  end
  
  def searchresult
    @title = "Search Results"
    @text = params[:searchText]
    @capacity = params[:capacity].to_i
    @category = params[:category]
    @startDate = DateTime.civil(params[:search][:"startDate(1i)"].to_i,
                        params[:search][:"startDate(2i)"].to_i,
                        params[:search][:"startDate(3i)"].to_i) 
    @endDate = @startDate
    @startTime = time_to_seconds(params[:search][:"startTime(4i)"], 
                                params[:search][:"startTime(5i)"], "23:59")
    @endTime = time_to_seconds(params[:search][:"endTime(4i)"],
                              params[:search][:"endTime(5i)"], "0:00")
    @startTime_upper = time_to_seconds(params[:search][:"startTime(4i)"],
                                params[:search][:"startTime(5i)"], "0:00")
    @endTime_lower = time_to_seconds(params[:search][:"endTime(4i)"],
                              params[:search][:"endTime(5i)"], "23:59")
    @duration = 0

    @temp = ReservationSystem.search @text, # Search for matching systems
      :conditions =>{:category => @category}
    
    if not params[:search][:"startTime(4i)"].empty?
      @startDate = @startDate.advance(:seconds => @startTime)
      @endDate = @startDate
    end
    if not params[:search][:"endTime(4i)"].empty?
      @endDate = @endDate.advance(:seconds => @endTime)
      if params[:search][:"startTime(4i)"].empty?
        @startDate = @endDate
      else # both start and end Time set, check duration
        if params[:duration_radio]=='2'
          @duration = time_to_seconds(params[:duration_hr], params[:duration_min], "01:00")
        else
          @duration = @endTime - @startTime
        end
      end
    end

    @results = []
    @resourceCount = [] # Stores number of available resource per system
    hasAvailable = false
    for i in 0...@temp.length do
      count = 0
      @sysReservations = getSystemReservationOverlap(@temp[i].id,  @startDate, @endTime_lower, @startTime_upper )
      @overlapDuration = getOverlapDuration( @sysReservations, @startTime_upper, @endTime_lower)
      @resources =  getResources(@text, @capacity, @temp[i].id, @startTime, @endTime,  @startTime_upper, @endTime_lower)
      for j in 0...@resources.length do # Filter by available reservation slots 
          @reservations = getReservationOverlap(@resources[j].id, @startDate, @startTime_upper, @endTime_lower)
  
          if @duration == 0  # Not set yet, make it to be Entire Duration from start to endtime
            currDuration = [@endTime_lower,@resources[j].endTime.to_i].min - [@startTime_upper,@resources[j].startTime.to_i].max
          else
            currDuration = @duration
          end
          @overlapDuration += getOverlapDuration(@reservations, @startTime_upper, @endTime_lower)
          currDuration -= @overlapDuration # Subtract every reserved slot 
          if (@duration ==0 and currDuration > 0) or (@duration != 0 and currDuration >= @duration) # Found at least one resource available
            count += 1
          end
      end
      if (count > 0)
        @results.push(@temp[i])
        @resourceCount.push(count)
      end
    end
    @results = @results.paginate(:page => params[:page], :per_page => 10)

    if @results.empty?
      flash[:error]= 'No matches found.'
      render 'searchform'
    else
      render :layout => "map"
    end 
  end

  def resourceresult
    @title = "Search Results"
    @capacity = params[:capacity].to_i
    @category = params[:category]
    @startDate = params[:startDate]
    @text = params[:text]
    @startTime = params[:startTime].to_i
    @endTime = params[:endTime].to_i
    @startTime_upper = params[:startTimeUpper].to_i
    @endTime_lower = params[:endTimeLower].to_i
    @duration = params[:duration].to_i
    @reservationID = params[:reservationID]
    @reservationSystem =  ReservationSystem.find(@reservationID)
    @results = []
    # Get all resources matching text and capacity etc.
    @temp = getResources(@text, @capacity, @reservationID, @startTime, @endTime, @startTime_upper, @endTime_lower)
    @sysReservations = getSystemReservationOverlap(@reservationID, Date.parse(@startDate), @endTime_lower, @startTime_upper )
    @overlapSysDuration = getOverlapDuration( @sysReservations, @startTime_upper, @endTime_lower)
    # Filter by availability of reservations
    for j in 0...@temp.length do 
      @reservations = getReservationOverlap(@temp[j].id, @startDate, @startTime_upper, @endTime_lower )
      if @duration == 0  # Not set yet, make it to be Entire Duration from start to endtime
        @currDuration = [@endTime_lower,@temp[j].endTime.to_i].min - [@startTime_upper,@temp[j].startTime.to_i].max
      else
        @currDuration = @duration
      end
      @overlapResDuration = getOverlapDuration(@reservations, @startTime_upper, @endTime_lower)
      @currDuration = @currDuration - @overlapSysDuration - @overlapResDuration # Subtract every reserved slot 
      if (@duration ==0 and @currDuration > 0) or (@duration != 0 and @currDuration >=@duration) # Resource has available slot in requested time
        @results.push(@temp[j])
      end
    end

    @floorplans = ReservationFloorplan.find(:all, :conditions => {:reservation_system_id => @reservationID})
    @imgmaps = []
    for i in 0...@floorplans.length do
      @temp = Resource.find(:all, :conditions => {:reservation_floorplan_id => @floorplans[i].id})
      img = '<img class="map" alt= "' +@floorplans[i].caption + '" src= "' + image_path(@floorplans[i].floorplan.url(:large)) + '" USEMAP = "#floorplan' + @floorplans[i].id.to_s + '" />'
      img += '<map name= "floorplan' + @floorplans[i].id.to_s + '" />'
      for j in 0...@temp.length do
	if not @temp[j].html.nil? 
	        img += @temp[j].html
	end
      end
      img += '</map>'
      @imgmaps.push(img)
    end
    @test = "<h2>test</h2> "
    @results = @results.paginate(:page => params[:page], :per_page => 10)
  end

  def resourcestatus
    @title = 'Select Your TimeSlots'

    @resource = Resource.find(params[:resourceID])
    @date = params[:startDate]
    if @resource.min_duration.blank?
      @min_duration = 60
    else
      @min_duration = @resource.min_duration.to_i
    end
    @startTime = @resource.startTime.to_i
    @endTime = @resource.endTime.to_i 
    @timeArr = []
    temp = @startTime
    while temp < @endTime 
      @timeArr.push(temp)
      temp = temp + @min_duration 
    end
    @reservedSlots = Reservation.search :with => {:resource_id => @resource.id, 
      :startDate => (Time.parse(@date)-3.day)...(Time.parse(@date)+3.day)}
    @sysReservedSlots = SystemReservation.find(:all, :conditions => ['reservation_system_id = ? 
                      and TIME_TO_SEC(TIME(startDate))<? and TIME_TO_SEC(TIME(endDate)) > ?', @resource.reservation_system_id, @endTime, @startTime] )
  end

  def confirmreservation
    @title = 'Check and Confirm Reservation'
    @resource = Resource.find(params[:resourceID])
    @startDate = params[:startDate]
    @endDate = params[:endDate]
    @reservation = Reservation.new
  end

  def createreservation
    @reservation = current_user.reservations.build(params[:reservation])
    @reservation.user_id = current_user.id
    overlap = Reservation.find(:all, :conditions => ['resource_id = ? and startDate <? and endDate > ?', @reservation.resource_id,  @reservation.endDate, @reservation.startDate] )
    if overlap.length == 0 and @reservation.save 
      flash[:success] = "You have successfully made a reservation!"
      redirect_to checkreminder_path( :reservationid => @reservation.id)
    else
      flash[:error] = "An error has occurred when processing the reservation. The slot may have been reserved. Please try again"
      render 'index'
    end 
  end

  def checkreminder 
    @reservation = Reservation.find_by_id(params[:reservationid])
  end

private
  def time_to_seconds(hour, min, default)
    return hour.to_i*3600 + min.to_i*60 if not hour.empty?
    time_arr = default.split(':')
    return  time_arr[0].to_i*3600 + time_arr[1].to_i*60
  end

  def getSystemReservationOverlap(id, startDate, endTime, startTime)
    return SystemReservation.find(:all, :conditions => ['reservation_system_id = ? and ((recurring = "One Time" and DATE(startDate) = ?) or (recurring = "Weekly" and DAYNAME(startDate) = ?) or (recurring = "Monthly" and DAYOFMONTH(StartDate) = ?)) and TIME_TO_SEC(TIME(startDate))<? and TIME_TO_SEC(TIME(endDate)) > ?', id,  startDate.strftime('%F'),  startDate.strftime('%A'), startDate.strftime('%d'), endTime, startTime] )
  end

  def getReservationOverlap(id, startDate, startTime, endTime)
    return Reservation.search  :condition => {:status => 'confirmed'},
                                              :with => { :resource_id => id, :startDate => startDate.to_time.to_i,
                                                        :startTime => 0..endTime, :endTime => startTime...0xffffffff}
  end

  def getResources(text, capacity, id, startTime, endTime, startTime_upper, endTime_lower)
    return  Resource.search text,  # Filter by resources capacity and start/end Time
        :with => {:capacity => capacity...0xffffffff, :reservation_system_id => id,
                :startTime_i => 0..startTime, :startTime_i => 0..endTime_lower,
                :endTime_i => endTime...0xffffffff , :endTime_i => startTime_upper...0xffffffff}
  end

  def getOverlapDuration(reservations, startTime, endTime)
    duration = 0
      for i in 0...reservations.length
        duration += [reservations[i].endDate.to_i % (24*60*60), endTime].min - [reservations[i].startDate.to_i % (24*60*60), startTime].max 
       end
     return duration
  end

end
