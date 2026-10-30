class PasswordsController < ApplicationController
  before_action :require_user
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to edit_password_path, flash: { danger: t('passwords.update.rate_limited') } }

  def edit
    @password_change = PasswordChange.new
  end

  def update
    @password_change = PasswordChange.new(password_change_params.merge(user: current_user))

    if @password_change.save
      reset_session
      session[:user_token] = @password_change.user.generate_token_for(:session)
      flash[:success] = t('.changed')
      redirect_to home_path
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def password_change_params
    params.expect(password_change: [:current_password, :new_password, :new_password_confirmation])
  end
end
