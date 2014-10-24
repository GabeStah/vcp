class UsersController < ApplicationController
  load_and_authorize_resource

  before_action :set_user,       only: [:destroy, :edit, :manual_sign_in, :show, :update]

  def create
    @user = User.new(user_params)
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to VCP!"
      redirect_to @user
    else
      render :new
    end
  end

  def destroy
    @user.destroy
    flash[:success] = "User deleted."
    redirect_to users_url
  end

  def edit
  end

  def ghost
    authorize! :ghost, @user
    if Rails.env.development?
      sign_in(:user, @user)
      flash[:success] = "Successfully ghosting as #{@user.name}."
      redirect_to user_path(@user)
    else
      flash[:warning] = "Unable to ghost as #{@user.name}."
      redirect_to :back
    end
  end

  def index
    @users = User.all.order(:battle_tag)
  end

  def new
    @user = User.new
  end

  def show
  end

  def update
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
    end
  end

  private
    def user_params
      params.require(:user).permit(:battle_tag, :password,
                                   :password_confirmation)
    end
    def set_user
      @user = User.find(params[:id])
    end
end
