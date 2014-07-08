class UsersController < ApplicationController
  before_action :set_user,       only: [:destroy, :edit, :show, :update]
  before_action :require_login,  only: [:edit, :update]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

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

  def index
    @users = User.paginate(page: params[:page]).order(:name)
  end

  def new
    @user = User.new
  end

  def show
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render :edit
    end
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
    def set_user
      @user = User.find(params[:id])
    end
end
