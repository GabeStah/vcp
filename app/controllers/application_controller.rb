class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  include SessionsHelper

  helper_method :user_owns_character?

  private

  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end

  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end

  def require_login
    store_location
    redirect_to signin_url, notice: "Please sign in." unless signed_in?
  end

  def user_owns_character?(character = nil)
    if current_user && current_user.characters.include?(character.present? ? character : @character)
      @owned_character = true
      return true
    end
    @owned_character = false
    return false
  end
end
