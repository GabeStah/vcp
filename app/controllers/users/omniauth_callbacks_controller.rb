class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def bnet
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      # Pull character data
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Bnet") if is_navigational_format?
    else
      session["devise.bnet_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to new_user_registration_url
  end

  def force_ssl
    true
  end
end