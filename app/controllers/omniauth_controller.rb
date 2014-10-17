class OmniauthController < ApplicationController
  def callback
    auth = request.env["omniauth.auth"]
    logger.info "BATTLE_NET_AUTH: Users#callback uid:#{auth["uid"]}, info:#{auth["info"]}"
    session[:user_id] = auth["uid"]
    session[:user_info] = auth["info"]
  end

  def failure
    logger.info "BATTLE_NET_AUTH: Users#failure <h1>Authentication Failed:</h1><h3>message:#{params[:message]}<h3> <pre>#{params}</pre>"
  end

  def signin
    logger.info "BATTLE_NET_AUTH: Users#signin"
    redirect_to '/auth/bnet'
  end
end