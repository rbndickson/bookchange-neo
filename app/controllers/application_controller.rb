class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user, :logged_in?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def require_user
    access_denied unless logged_in?
  end

  def access_denied
    if logged_in?
      flash[:danger] = t('access_denied.logged_in')
      redirect_to home_path
    else
      flash[:danger] = t('access_denied.not_logged_in')
      redirect_to login_path
    end
  end

  def redirect_logged_in_user
    redirect_to home_path if logged_in?
  end
end
