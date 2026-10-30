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
  validates :password, presence: true, on: :change_password
  validates :password, length: { minimum: 8 }, on: [:create, :change_password]
  validates :password_confirmation, presence: true, on: [:create, :change_password]

  attr_accessor :current_password

  validates :current_password, presence: true, on: [:update_account, :change_password]
  validate :current_password_correct, on: [:update_account, :change_password], if: -> { current_password.present? }

  private

  def current_password_correct
    # Checked against the saved password, as a new one may already be set on this record.
    return if BCrypt::Password.new(password_digest_was).is_password?(current_password)

    errors.add(:current_password, :incorrect)
  end
end
