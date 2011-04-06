class UsersController < ApplicationController
  before_filter :authenticate, :only => [:show, :edit, :update, :upgrade]
  before_filter :authorized_user, :only => [:show, :edit, :update, :upgrade]

  def new
    @user = User.new
    @title = "Sign Up"
  end

  def new_vendor
    @user = User.new
    @title = "Vendor Sign Up"
  end 

  def show
    if @user.user_type == 'business' and params[:mode]=='business'
      @title = "Manage My Resources"
    else
      @title = "Manage My Reservations"
    end
    @reservationSystems = @user.reservation_systems.paginate(:page => params[:page], :per_page => 10)
    @reservations = [];
    for systems in @user.reservation_systems do
      for resources in systems.resources do
        @reservations.concat(resources.reservations)
      end
    end
    @reservations.sort!{|b,a|a.updated_at <=> b.updated_at}
    @reservations = @reservations.paginate(:page => params[:page], :per_page => 10)
    @myreservations = @user.reservations.paginate(:page => params[:page], :order => 'updated_at DESC', :per_page => 10)
    @ratings = Rating.find(:all)
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Reservation System!"
      if @user.user_type == 'business'
        redirect_to user_path(@user, :mode=>'business')
      else
        redirect_to @user
      end
    elsif @user.user_type == 'business'
        render 'new_vendor'  
    else 
        render 'new'
    end
  end

  def edit
    @title = "Edit user profile"
  end
  
  def upgrade
    @title = "Upgrade to Vendor Account"
  end
  
  def update   
    if @user.update_attributes(params[:user])
      flash[:success] = "Profile updated."
      redirect_to @user
    else
      @title = "Edit user profile"
      render 'edit'
    end
  end

private

    def authorized_user
      @user = User.find(params[:id])
      if not current_user?(@user)
        flash[:error] = "You are not authorized to access the page"
        redirect_to root_path
      end
    end
end
