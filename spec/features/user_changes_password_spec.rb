require 'rails_helper'

feature 'user changes password' do
  let(:alice) { Fabricate(:alice) }

  before { log_in(alice) }

  scenario 'from the Update Account page' do
    visit edit_user_path(alice)
    click_link 'Change Password'
    expect(page).to have_css('h3', text: 'Change Password')
    ['Current Password', 'New Password', 'Confirm New Password'].each do |label|
      expect(find_field(label).value).to be_blank
    end
    expect(page).to have_button('Change Password')
  end

  scenario 'with valid details' do
    change_password
    expect(page).to have_current_path(home_path)
    expect(page).to have_content('Your password was changed.')
    expect_to_be_logged_in_as_alice
  end

  scenario 'and logs in with the new password' do
    change_password
    log_out
    log_in_with_password('password')
    expect(page).to have_content('Log in error, please try again.')
    log_in_with_password('newpassword')
    expect(page).to have_current_path(home_path)
  end

  scenario 'logs out their other sessions' do
    Capybara.using_session(:other_browser) do
      log_in(alice)
      expect_to_be_logged_in_as_alice
    end

    change_password

    Capybara.using_session(:other_browser) do
      visit home_path
      expect(page).to have_current_path(login_path)
      expect(page).to have_content('You must be logged in to do that.')
    end
    visit home_path
    expect(page).to have_current_path(home_path)
  end

  scenario 'with blank fields' do
    change_password(current_password: '', new_password: '', confirmation: '')
    expect_field_error('Current Password', "Current Password can't be blank")
    expect_field_error('New Password', "New Password can't be blank")
    expect_field_error('Confirm New Password', "Confirm New Password can't be blank")
  end

  scenario 'with a wrong current password' do
    change_password(current_password: 'wrong password')
    expect_field_error('Current Password', 'Current Password is incorrect')
    expect_password_unchanged
  end

  scenario 'with new passwords that do not match' do
    change_password(confirmation: 'something else')
    expect_field_error('Confirm New Password', "Confirm New Password doesn't match New Password")
    expect_password_unchanged
  end

  scenario 'with a new password that is too short' do
    change_password(new_password: 'short')
    expect_field_error('New Password', 'New Password is too short (minimum is 8 characters)')
  end

  scenario 'with a new password that is too long' do
    change_password(new_password: 'a' * 73)
    expect_field_error('New Password', 'New Password is too long (maximum is 72 characters)')
  end

  scenario 'sees all fields empty after a failed save' do
    change_password(confirmation: 'something else')
    ['Current Password', 'New Password', 'Confirm New Password'].each do |label|
      expect(find_field(label).value).to be_blank
    end
  end

  scenario 'more than 10 times within 3 minutes' do
    10.times { change_password(current_password: 'wrong password') }
    change_password
    expect(page).to have_current_path(edit_password_path)
    expect(page).to have_content('Try again later.')
    expect_password_unchanged
  end

  def change_password(current_password: 'password', new_password: 'newpassword', confirmation: new_password)
    visit edit_password_path
    fill_in 'Current Password', with: current_password
    fill_in 'New Password', with: new_password
    fill_in 'Confirm New Password', with: confirmation
    click_button 'Change Password'
  end

  def log_out
    within('nav') { click_button 'Log Out' }
  end

  def log_in_with_password(password)
    visit login_path
    fill_in 'Email', with: 'alice@example.com'
    fill_in 'Password', with: password
    click_button 'Log In'
  end

  def expect_to_be_logged_in_as_alice
    within('nav') { expect(page).to have_button('alice') }
  end

  def expect_password_unchanged
    expect(alice.reload.authenticate('password')).to eq(alice)
  end
end
