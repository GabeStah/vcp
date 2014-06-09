class StaticPagesController < ApplicationController
  before_action :require_login, only: :settings
  before_action :is_admin_user, only: :settings

  def about
  end
  def contact
  end
  def help
  end
  def home
  end
  def settings
  end
end
