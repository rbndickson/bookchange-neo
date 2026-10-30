class User < ApplicationRecord
  has_secure_password

  # Based on the password, so changing it logs out other sessions (KI-018).
  generates_token_for :session do
    password_salt.last(10)
  end

  normalizes :email, with: ->(email) { email.strip.downcase }
  normalizes :username, with: ->(username) { username.strip }

  validates :email, presence: true,
                    length: { maximum: 254, allow_blank: true },
                    format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true },
                    uniqueness: true
  validates :username, presence: true,
                       length: { in: 2..20, allow_blank: true },
                       uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 }, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  attr_accessor :current_password

  validates :current_password, presence: true, on: :update, if: :will_save_change_to_email?
  validate :current_password_correct, on: :update,
                                      if: -> { will_save_change_to_email? && current_password.present? }

  private

  def password_required? = new_record? || !password.nil?

  def current_password_correct
    errors.add(:current_password, :incorrect) unless authenticate(current_password)
  end
end
