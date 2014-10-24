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
      flash[:error] = "Unable to ghost as #{@user.name}."
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
    @roles = Role.all.order(:name)
  end

  def toggle_role
    @role = Role.find(params[:role_id])
    if @role
      if @user.roles.include?(@role)
        # Ensure not a settings role for user
        if @user.has_role_from_settings?(@role)
          flash[:error] = "#{@role.name.titleize} role assigned to #{@user.name} in configuration file.  Unable to revoke access."
        else
          # remove
          @user.roles.delete(@role)
          flash[:success] = "#{@role.name.titleize} access removed from #{@user.name}."
        end
      else
        # add
        @user.roles << @role
        @user.save
        flash[:success] = "#{@role.name.titleize} access granted to #{@user.name}."
      end
    else
      flash[:error] = "Role not found."
    end
    redirect_to user_path(@user)
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
