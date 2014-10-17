class RegistrationsController < Devise::RegistrationsController
  before_filter :configure_permitted_parameters, :only => [:create, :update]

  protected

  def after_update_path_for(resource)
    user_path(resource)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up)        { |u| u.permit(:name, :email, :password) }
    devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:name, :email, :password, :password_confirmation, :current_password) }
  end
end