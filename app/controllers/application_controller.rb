class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  around_filter :set_timezone

  # Auto-call param retrieval for controllers
  before_filter do
    resource = controller_name.singularize.to_sym
    method = "#{resource}_params"
    params[resource] &&= send(method) if respond_to?(method, true)
  end

  helper_method :user_owns_character?

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end

  private

  def set_timezone
    default_timezone = Time.zone
    client_timezone  = cookies[:timezone]
    Time.zone = client_timezone if client_timezone.present?
    yield
  ensure
    Time.zone = default_timezone
  end

  def user_owns_character?(character = nil)
    if current_user && current_user.characters.include?(character.present? ? character : @character)
      @owned_character = true
      return true
    end
    @owned_character = false
    false
  end
end
