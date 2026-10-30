Fabricator(:user) do
  email { sequence(:email) { |number| "user#{number}@example.com" } }
  username { sequence(:username) { |number| "user#{number}" } }
  password 'password'
  password_confirmation 'password'
end
