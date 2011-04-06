class ReservationsController < ApplicationController

  before_filter :authenticate
  before_filter :authorized_user

def show
  @title = 'Reservations Details'
  @user = current_user
  @resource = @reservation.resource
  @reservationSystem = @resource.reservation_system  
end

def create
end

def cancel
  @resource = @reservation.resource
  if @resource.allowcancel?
    @reservation.status = 'Cancelled'
    if @reservation.save
      flash[:success] = "You have cancelled the reservation"
      redirect_to current_user
    else
      flash[:error] = "Unable to cancel the reservation"
      redirect_to :back
    end
  else
    flash[:error] = "The owner of the reservation system does not allow cancellations."
    redirect_to :back
  end
end

private
  def authorized_user
    @reservation = Reservation.find(params[:id])
      if not current_user?(@reservation.user)
        flash[:error] = "You are not authorized to access the page"
        redirect_to root_path
      end
  end
end


