class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user
  helper_method :confirm_logged_in
  protected

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  def confirm_logged_in
    unless current_user
      redirect_to log_in_url, :notice => "Please log in."
      return false
    else
      return true
    end
  end
end
