class ReservationSystemsController < ApplicationController

  before_filter :authenticate
  before_filter :authorized_user, :except => [:new, :create]

  def new
    @reservationSystem = ReservationSystem.new
    @title = 'Add New Reservation System'
  end

  def create
    @reservationSystem = current_user.reservation_systems.build(params[:reservationSystem])
    if @reservationSystem.save
      flash[:success] = "You have successfully added a new Reservation System"
      redirect_to set_location_user_reservationSystem_path(current_user,@reservationSystem)
    else
        render 'new'
    end
  end

  def set_location
    render :layout => "map"
   @title = 'Select location'
  end

  def show_location
    render :layout => "map"
    @title = 'Location on Map'
  end

  def update
    if (params[:action]== 'edit')
      if not @reservationSystem.address.eql?(params[:reservation_system][:address]) # Address changed
        if @reservationSystem.update_attributes(params[:reservation_system]) 
          @reservationSystem.update_attribute(:location, '')
          redirect_to set_location_user_reservationSystem_path(current_user, @reservationSystem)
        else
          @title = 'Edit System Information'
          render 'edit'
        end
      elsif @reservationSystem.update_attributes(params[:reservation_system]) # No address change, change successful
          flash[:success] = "Updated successfully."
          redirect_to  user_path(current_user, :mode =>  'business')
      else
        @title = 'Edit System Information'
        render 'edit'
      end
    else # set_location
      if @reservationSystem.update_attributes(params[:reservation_system])
          flash[:success] = "Updated successful."
          redirect_to  user_path(current_user, :mode =>  'business')
      else
        @title = "Select location"
        render 'set_location'
      end
    end
  end

  def show
    @title = 'Manage My Reservation System'
    @user = current_user
    @resources = @reservationSystem.resources.paginate(:page => params[:page], :per_page => 10)
    @reservations = []
    @systemReservations  = @reservationSystem.system_reservations.paginate(:page => params[:page], :per_page => 10)
    for resources in @reservationSystem.resources
      @reservations.concat(resources.reservations)
    end
    @reservations.sort!{|b,a|a.updated_at <=> b.updated_at}
    @reservations = @reservations.paginate()
    @floorplans = @reservationSystem.reservation_floorplans     
  end

  def edit
    @title = 'Edit System Information'
    @user = current_user
  end

  def destroy
    ReservationSystem.find(params[:id]).destroy
    flash[:success] = 'You have removed the Reservation System'
    redirect_to user_path(current_user, :mode => 'business')
  end

private
  def authorized_user
    @reservationSystem = ReservationSystem.find(params[:id])
      if not current_user?(@reservationSystem.user)
        flash[:error] = "You are not authorized to access the page"
        redirect_to root_path
      end
  end

end
