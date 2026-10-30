class UsersController < ApplicationController
  before_action :redirect_logged_in_user_to_home_path

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = t('.joined')
      redirect_to login_path
    else
      render :new, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [:email, :username, :password, :password_confirmation])
  end
end
