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
    if sign_in(:user, @user)
      flash[:success] = "Successfully ghosting as #{@user.name}."
      redirect_to user_path(@user)
    else
      flash[:error] = "Unable to ghost as #{@user.name}."
      redirect_to user_path(@user)
    end
  end

  def index
    @users = User.all.order(:battle_tag)
    respond_to do |format|
      format.html
      format.json do
        render json: UserDatatable.new(view_context)
      end
    end
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
    respond_to do |format|
      if @user.update(user_params)
        format.html {
          flash[:success] = "Profile updated"
          redirect_to @user
        }
        format.json do
          # Update all characters created_at if changed
          if user_params['created_at']
            @user.characters.update_all(created_at: @user.created_at)
          end
          respond_with_bip(@user)
        end
      else
        format.html { render :edit }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  private
    def user_params
      params.require(:user).permit(:battle_tag,
                                   :created_at,
                                   :password,
                                   :password_confirmation,
                                   :show_hidden_characters)
    end
    def set_user
      @user = User.find(params[:id])
    end
end
