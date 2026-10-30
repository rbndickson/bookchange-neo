require 'rails_helper'

feature 'user updates account' do
  let(:alice) { Fabricate(:alice) }

  before { log_in(alice) }

  scenario 'from the user menu', :js do
    within('nav') { click_button 'alice' }
    expect(page).to have_css('.dropdown-menu li:first-child', text: 'Update Account')
    expect(page).to have_css('.dropdown-menu li:last-child', text: 'Log Out')
    click_link 'Update Account'
    expect_update_account_form
  end

  scenario 'sees the form filled in with their details' do
    visit edit_user_path(alice)
    expect_update_account_form
    expect(find_field('Email').value).to eq('alice@example.com')
    expect(find_field('Username').value).to eq('alice')
    expect(find_field('Current Password').value).to be_blank
    expect(page).to have_button('Update')
    expect(page).to have_link('Change Password', href: edit_password_path)
  end

  scenario 'changes the username' do
    update_account(username: 'alice2')
    expect_profile_updated
    within('nav') { expect(page).to have_content('alice2') }
    expect(alice.reload.username).to eq('alice2')
  end

  scenario 'changes the email with the current password' do
    update_account(email: 'alice2@example.com', current_password: 'password')
    expect_profile_updated
    expect(alice.reload.email).to eq('alice2@example.com')
    expect(User.authenticate_by(email: 'alice2@example.com', password: 'password')).to eq(alice)
  end

  scenario 'changes the email with a blank current password' do
    update_account(email: 'alice2@example.com')
    expect_field_error('Current Password', "Current Password can't be blank")
    expect(alice.reload.email).to eq('alice@example.com')
  end

  scenario 'changes the email with a wrong current password' do
    update_account(email: 'alice2@example.com', current_password: 'wrong password')
    expect_field_error('Current Password', 'Current Password is incorrect')
    expect(find_field('Current Password').value).to be_blank
    expect(alice.reload.email).to eq('alice@example.com')
  end

  scenario 'with a blank email and username' do
    update_account(email: '', username: '')
    expect_field_error('Email', "Email can't be blank")
    expect_field_error('Username', "Username can't be blank")
    expect(alice.reload.username).to eq('alice')
  end

  scenario 'keeps the entered values after a failed save' do
    update_account(email: 'alice2@example.com', username: 'alice2', current_password: 'wrong password')
    expect(find_field('Email').value).to eq('alice2@example.com')
    expect(find_field('Username').value).to eq('alice2')
    expect(find_field('Current Password').value).to be_blank
    within('nav') { expect(page).to have_content('alice') }
    within('nav') { expect(page).to have_no_content('alice2') }
    expect(alice.reload.username).to eq('alice')
  end

  scenario 'with an email that already has an account' do
    Fabricate(:bob)
    update_account(email: ' Bob@Example.com ', current_password: 'password')
    expect_field_error('Email', 'Email cannot be used')
  end

  scenario 'with a username that is already taken' do
    Fabricate(:bob)
    update_account(username: 'Bob')
    expect_field_error('Username', 'Username has already been taken')
  end

  scenario 'with an invalid email' do
    update_account(email: 'alice', current_password: 'password')
    expect_field_error('Email', 'Email is invalid')
  end

  scenario 'with an email and username that are too long' do
    update_account(email: "#{"a" * 243}@example.com", username: 'a' * 21, current_password: 'password')
    expect_field_error('Email', 'Email is too long (maximum is 254 characters)')
    expect_field_error('Username', 'Username is too long (maximum is 20 characters)')
  end

  scenario 'with a username that is too short' do
    update_account(username: 'a')
    expect_field_error('Username', 'Username is too short (minimum is 2 characters)')
  end

  scenario 'changes the username only in letter case' do
    update_account(username: 'Alice')
    expect_profile_updated
    expect(alice.reload.username).to eq('Alice')
  end

  scenario 'saves without changes' do
    update_account
    expect_profile_updated
  end

  scenario 'saves more than 10 times within 3 minutes' do
    10.times { |number| update_account(username: "alice#{number}") }
    update_account(username: 'alice10')
    expect(page).to have_current_path(edit_user_path(alice))
    expect(page).to have_content('Try again later.')
    expect(alice.reload.username).to eq('alice9')
  end

  def update_account(email: nil, username: nil, current_password: nil)
    visit edit_user_path(alice)
    fill_in 'Email', with: email unless email.nil?
    fill_in 'Username', with: username unless username.nil?
    fill_in 'Current Password', with: current_password unless current_password.nil?
    click_button 'Update'
  end

  def expect_update_account_form
    expect(page).to have_css('h3', text: 'Update Account')
    ['Email', 'Username', 'Current Password'].each do |label|
      expect(page).to have_field(label)
    end
  end

  def expect_profile_updated
    expect(page).to have_current_path(home_path)
    expect(page).to have_content('Your profile was updated.')
  end
end
