class SystemReservationsController < ApplicationController

  before_filter :authenticate
  before_filter :authorized_user

  def new
    @title = 'Add New Rule To Your Reservation System'
    @systemReservation = SystemReservation.new
  end

  def create
    @systemReservation = @reservationSystem.system_reservations.build(params[:systemReservation])
    @systemReservation.startDate = DateTime.civil(params[:StartDate][:"Date(1i)"].to_i,
                        params[:StartDate][:"Date(2i)"].to_i, params[:StartDate][:"Date(3i)"].to_i, 
                        params[:StartDate][:"Time(4i)"].to_i, params[:StartDate][:"Time(5i)"].to_i)
    @systemReservation.endDate = DateTime.civil(params[:EndDate][:"Time(1i)"].to_i,
                        params[:EndDate][:"Time(2i)"].to_i, params[:EndDate][:"Time(3i)"].to_i,
                        params[:EndDate][:"Time(4i)"].to_i, params[:EndDate][:"Time(5i)"].to_i)


    if @systemReservation.save
      flash[:success] = "Updated successfully"
      redirect_to user_reservationSystem_path(current_user,@reservationSystem)
    else
        render 'new'
    end
  end

  def destroy
    @reservationSystem.system_reservations.find(params[:id]).destroy
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

end
