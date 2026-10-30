require 'rails_helper'

feature 'user signs up' do
  scenario 'from the header' do
    visit root_path
    within('nav') { click_link 'Sign Up' }
    expect_sign_up_form
  end

  scenario 'from the front page' do
    visit root_path
    within('main') { click_link 'Sign Up' }
    expect_sign_up_form
  end

  scenario 'with valid details' do
    visit signup_path
    fill_in_sign_up_form
    click_button 'Sign Up'
    expect(page).to have_current_path(login_path)
    expect(page).to have_content('You have joined Bookchange, you can now log in.')
    expect(User.find_by(email: 'alice@example.com').username).to eq('alice')
    expect_to_be_logged_out
  end

  scenario 'with blank fields' do
    visit signup_path
    fill_in_sign_up_form(email: 'alice@example.com', username: 'alice', password: '', confirmation: '')
    click_button 'Sign Up'
    expect_field_error('Password', "Password can't be blank")
    expect_field_error('Confirm Password', "Confirm Password can't be blank")
    expect(find_field('Email').value).to eq('alice@example.com')
    expect(find_field('Username').value).to eq('alice')
    expect(find_field('Password').value).to be_blank
    expect(User.count).to eq(0)
  end

  scenario 'with a blank email and username' do
    visit signup_path
    fill_in_sign_up_form(email: '', username: '')
    click_button 'Sign Up'
    expect_field_error('Email', "Email can't be blank")
    expect_field_error('Username', "Username can't be blank")
  end

  scenario 'with passwords that do not match' do
    visit signup_path
    fill_in_sign_up_form(confirmation: 'something else')
    click_button 'Sign Up'
    expect_field_error('Confirm Password', "Confirm Password doesn't match Password")
    expect(User.count).to eq(0)
  end

  scenario 'with a password that is too short' do
    visit signup_path
    fill_in_sign_up_form(password: 'short', confirmation: 'short')
    click_button 'Sign Up'
    expect_field_error('Password', 'Password is too short (minimum is 8 characters)')
  end

  scenario 'with a password that is too long' do
    visit signup_path
    fill_in_sign_up_form(password: 'a' * 73, confirmation: 'a' * 73)
    click_button 'Sign Up'
    expect_field_error('Password', 'Password is too long (maximum is 72 characters)')
  end

  scenario 'with an email that already has an account' do
    Fabricate(:alice)
    visit signup_path
    fill_in_sign_up_form(email: ' Alice@Example.com ', username: 'alice2')
    click_button 'Sign Up'
    expect_field_error('Email', 'Email cannot be used')
    expect(User.count).to eq(1)
  end

  scenario 'with a username that is already taken' do
    Fabricate(:alice)
    visit signup_path
    fill_in_sign_up_form(email: 'alice2@example.com', username: 'Alice')
    click_button 'Sign Up'
    expect_field_error('Username', 'Username has already been taken')
    expect(User.count).to eq(1)
  end

  scenario 'with an invalid email' do
    visit signup_path
    fill_in_sign_up_form(email: 'alice')
    click_button 'Sign Up'
    expect_field_error('Email', 'Email is invalid')
  end

  scenario 'with an email and username that are too long' do
    visit signup_path
    fill_in_sign_up_form(email: "#{"a" * 243}@example.com", username: 'a' * 21)
    click_button 'Sign Up'
    expect_field_error('Email', 'Email is too long (maximum is 254 characters)')
    expect_field_error('Username', 'Username is too long (maximum is 20 characters)')
  end

  scenario 'with a username that is too short' do
    visit signup_path
    fill_in_sign_up_form(username: 'a')
    click_button 'Sign Up'
    expect_field_error('Username', 'Username is too short (minimum is 2 characters)')
  end

  scenario 'when already logged in' do
    log_in(Fabricate(:alice))
    visit signup_path
    expect(page).to have_current_path(home_path)
  end

  def fill_in_sign_up_form(email: 'alice@example.com', username: 'alice', password: 'password',
                           confirmation: password)
    fill_in 'Email', with: email
    fill_in 'Username', with: username
    fill_in 'Password', with: password
    fill_in 'Confirm Password', with: confirmation
  end

  def expect_sign_up_form
    expect(page).to have_css('h3', text: 'Sign Up')
    ['Email', 'Username', 'Password', 'Confirm Password'].each do |label|
      expect(page).to have_field(label)
    end
  end

  def expect_field_error(label, message)
    field = find_field(label)
    expect(field[:class]).to include('is-invalid')
    expect(page).to have_css("##{field[:id]} ~ .invalid-feedback", text: message)
  end

  def expect_to_be_logged_out
    within('nav') { expect(page).to have_link('Log In') }
  end
end
