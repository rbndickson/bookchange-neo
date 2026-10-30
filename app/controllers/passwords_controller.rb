class PasswordsController < ApplicationController
  before_action :require_user
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to edit_password_path, flash: { danger: t('passwords.update.rate_limited') } }

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    @user.assign_attributes(password_params)

    if @user.save(context: :change_password)
      reset_session
      session[:user_token] = @user.generate_token_for(:session)
      flash[:success] = t('.changed')
      redirect_to home_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def password_params
    params.expect(user: [:current_password, :password, :password_confirmation])
  end
end
