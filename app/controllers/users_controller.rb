class UsersController < ApplicationController
  before_action :redirect_logged_in_user_to_home_path, only: [:new, :create]
  before_action :set_user, only: [:edit, :update]
  before_action :require_user, only: [:edit, :update]
  before_action :require_correct_user, only: [:edit, :update]
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to edit_user_path(current_user), flash: { danger: t('users.update.rate_limited') } }

  def new
    @user = User.new
  end

  def edit; end

  def create
    @user = User.new(user_params)

    if @user.save
      flash[:success] = t('.joined')
      redirect_to login_path
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @user.update(update_params)
      flash[:success] = t('.updated')
      redirect_to home_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def user_params
    params.expect(user: [:email, :username, :password, :password_confirmation])
  end

  def update_params
    params.expect(user: [:email, :username, :current_password])
  end

  def set_user
    @user = User.find_by(id: params[:id])
  end

  def require_correct_user
    access_denied unless @user == current_user
  end
end
