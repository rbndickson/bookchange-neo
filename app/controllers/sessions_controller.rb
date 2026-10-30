class SessionsController < ApplicationController
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to login_path, flash: { danger: t('.rate_limited') } }
  before_action :redirect_logged_in_user, only: [:new, :create]

  def new; end

  def create
    user = User.authenticate_by(email: params[:email], password: params[:password])

    if user
      reset_session
      session[:user_id] = user.id
      redirect_to home_path
    else
      flash[:danger] = t('.failed')
      redirect_to login_path
    end
  end
end
