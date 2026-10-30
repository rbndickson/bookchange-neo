class PasswordChange
  include ActiveModel::Model

  attr_accessor :user, :current_password, :new_password, :new_password_confirmation

  validates :current_password, presence: true
  validate :current_password_correct, if: -> { current_password.present? }
  validates :new_password, presence: true, length: { minimum: 8 }, confirmation: true
  validates :new_password_confirmation, presence: true
  validate :new_password_not_too_long

  def save
    valid? && user.update(password: new_password, password_confirmation: new_password_confirmation)
  end

  private

  def current_password_correct
    errors.add(:current_password, :incorrect) unless user.authenticate(current_password)
  end

  def new_password_not_too_long
    return unless new_password.to_s.bytesize > ActiveModel::SecurePassword::MAX_PASSWORD_LENGTH_ALLOWED

    errors.add(:new_password, :password_too_long)
  end
end
