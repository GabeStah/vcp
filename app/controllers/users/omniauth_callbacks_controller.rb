class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def bnet
    logger.info 'BATTLE_NET_AUTH: Controller#bnet'
    # @user = User.from_omniauth(request.env["omniauth.auth"])
    # sign_in_and_redirect @user

    # You need to implement the method below in your model (e.g. app/models/user.rb)
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
      set_flash_message(:notice, :success, :kind => "Bnet") if is_navigational_format?
    else
      session["devise.bnet_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def failure
    logger.info 'BATTLE_NET_AUTH: Controller#failure'
    set_flash_message :alert, :failure, kind: OmniAuth::Utils.camelize(failed_strategy.name), reason: failure_message
    redirect_to new_user_registration_url
  end


  # def self.provides_callback_for(provider)
  #   class_eval %Q{
  #     def #{provider}
  #       @user = User.find_for_oauth(env["omniauth.auth"], current_user)
  #
  #       if @user.persisted?
  #         sign_in_and_redirect @user, event: :authentication
  #         set_flash_message(:notice, :success, kind: "#{provider}".capitalize) if is_navigational_format?
  #       else
  #         session["devise.#{provider}_data"] = env["omniauth.auth"]
  #         redirect_to new_user_registration_url
  #       end
  #     end
  #   }
  # end
  #
  # [:bnet].each do |provider|
  #   provides_callback_for provider
  # end
  #
  # def after_sign_in_path_for(resource)
  #   if resource.email_verified?
  #     super resource
  #   else
  #     finish_signup_path(resource)
  #   end
  # end
end