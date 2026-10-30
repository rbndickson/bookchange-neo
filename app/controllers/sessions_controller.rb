class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to login_path, flash: { danger: t('.rate_limited') } }
  before_action :redirect_logged_in_user_to_home_path, only: [:new, :create]

  def new; end

  def create
    user = User.authenticate_by(email: log_in_params[:email], password: log_in_params[:password])

    if user
      reset_session
      session[:user_id] = user.id
      redirect_to home_path
    else
      flash[:danger] = t('.failed')
      redirect_to login_path
    end
  end

  def destroy
    reset_session
    flash[:info] = t('.logged_out')
    redirect_to root_path
  end

  private

  def log_in_params
    params.permit(:email, :password)
  end
end
