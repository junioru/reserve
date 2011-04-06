class ResourcesController < ApplicationController
  uses_tiny_mce :options =>   { :theme => 'advanced',:plugins => %w{imgmap inlinepopups},  
                                :theme_advanced_buttons3 => "", :theme_advanced_buttons2 => "", 
                                :theme_advanced_buttons1 => "imgmap"}

  before_filter :authenticate
  before_filter :authorized_user

  def new
    @title = 'Add New Entry to System'
    @existingResources = @reservationSystem.resources
    @resource = Resource.new
    unless @existingResources.empty?
      @existingResources.sort!{|b,a|a.updated_at <=> b.updated_at}
      @resource.description = @existingResources[0].description
      @resource.startTime = formatTime(@existingResources[0].startTime.to_i)
      @resource.endTime = formatTime(@existingResources[0].endTime.to_i)
      @resource.min_duration = @existingResources[0].min_duration/60
    end
    @existingFloorplans = @reservationSystem.reservation_floorplans
  end

  def create
    @resource = @reservationSystem.resources.build(params[:resource])
    if @reservationSystem.category == 'Appointment'
	@resource.capacity = 1
    end
    @resource.reservation_system_id = @reservationSystem.id
    @existingFloorplans = @reservationSystem.reservation_floorplans
    if (params[:floorplan_radio] == '2')
      @floorplan = @reservationSystem.reservation_floorplans.build(params[:reservation_floorplan])
      @floorplan.reservation_system_id = @reservationSystem.id
      if @floorplan.save
        flash[:success] = "You have uploaded a new floorplan"
        @resource.reservation_floorplan_id = @floorplan.id
      else
        flash[:error] = "Select a valid image file and fill in the caption"
        render :action => 'new'
        return
      end
    end
    if (params[:floorplan_radio] == '3')
      if  ReservationFloorplan.exists?(params[:floorplanId])
        @resource.reservation_floorplan_id = params[:floorplanId]
      else
        flash[:error] = "Select a valid floorplan"
        render :new
        return
      end
    end
    if @resource.save
      flash[:success] = "You have successfully added an entry"
      if (params[:floorplan_radio] == '1')
        redirect_to user_reservationSystem_path(current_user,@reservationSystem)
      else
        redirect_to imgmap_user_reservationSystem_resource_path(current_user,@reservationSystem, @resource)
      end
    else
      render :new
    end
  end

  def imgmap
    @title = 'Select Area Of the Resource'
    @resource = Resource.find(params[:id])
    @floorplan = @resource.reservation_floorplan
  end
  
  def update
    @resource = Resource.find(params[:id])
    if params[:resource][:html].nil? #from edit page
      no_floorplan = @resource.reservation_floorplan.nil?
      if params[:changeFloorplan]== '1' or no_floorplan # Need to check for floorplan changes
        if (params[:floorplan_radio] == '2')
          @floorplan = @reservationSystem.reservation_floorplans.build(params[:reservation_floorplan])
          @floorplan.reservation_system_id = @reservationSystem.id
          if @floorplan.save
            flash[:success] = "You have uploaded a new floorplan"
            @resource.reservation_floorplan_id = @floorplan.id
          else
            render :action => 'new'
            return
          end
        elsif (params[:floorplan_radio] == '3')
          if  ReservationFloorplan.exists?(params[:floorplanId])
            @resource.reservation_floorplan_id = params[:floorplanId]
          else
            flash[:error] = "Select a valid floorplan"
            render :new
            return
          end
        elsif (params[:floorplan_radio] == '1' and not no_floorplan) # clear existing floorplan
          @resource.reservation_floorplan_id = ''
          @resource.html = ''
        end
      end
      if @resource.update_attributes(params[:resource])
        flash[:success] = "You have successfully updated the entry"
        if (params[:changeFloorplan] == '1' or no_floorplan) and params[:floorplan_radio] != '1'
          redirect_to imgmap_user_reservationSystem_resource_path(current_user,@reservationSystem, @resource)
        else
          redirect_to user_reservationSystem_path(current_user,@reservationSystem)
        end
      else
        render :edit
      end
    else # From imgmap page
      if @html == "" or params[:resource][:html].index('<area').nil?
	redirect_to user_reservationSystem_path(current_user, @reservationSystem)
        return
      end	
      index =  params[:resource][:html].index('<area')
      @html = params[:resource][:html][index..params[:resource][:html].length]
      index = @html.index('/>')
      @html = @html[0..index-1]+ ' href="#resource' + @resource.id.to_s + '" id="inline"/>'
      @resource.startTime = formatTime(@resource.startTime.to_i) # Converts to handle before_save convert to sec method 
      @resource.endTime = formatTime(@resource.endTime.to_i)
      @resource.min_duration = @resource.min_duration/60
      if @resource.update_attribute(:html, @html)
        flash[:success] = "Profile updated"
        redirect_to user_reservationSystem_path(current_user, @reservationSystem)
      else
        @title = "Edit user profile"
        render 'new'
      end
    end
  end

  def show
    @title = 'Resource Details'
    @resource = Resource.find(params[:id])
    @resource.startTime = formatTime(@resource.startTime.to_i)
    @resource.endTime  = formatTime(@resource.endTime.to_i)
    @reservations = @resource.reservations.sort!{|b,a|a.updated_at <=> b.updated_at}
    @reservations = @reservations.paginate(:page => params[:page],:per_page=>10)
  end
  
  def edit
    @title = 'Edit Resource'
    @resource = Resource.find(params[:id])
    @resource.startTime = formatTime(@resource.startTime.to_i)
    @resource.endTime = formatTime(@resource.endTime.to_i)
    @resource.min_duration = @resource.min_duration/60
    @existingFloorplans = @reservationSystem.reservation_floorplans
  end

  def destroy
    Resource.find(params[:id]).destroy
    flash[:success] = 'You have removed the entry'
    redirect_to user_reservationSystem_path(current_user, @reservationSystem)
  end

private 
  def authorized_user
    @reservationSystem = ReservationSystem.find(params[:reservationSystem_id])
      if not current_user?(@reservationSystem.user)
        flash[:error] = "You are not authorized to access the page"
        redirect_to root_path
      end
  end

  def formatTime(seconds)
  return  [seconds / 3600, seconds/ 60 % 60 ].map{ |t| t.to_s.rjust(2, '0') }.join(':')  
  end
end
