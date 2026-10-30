require 'rails_helper'

feature 'user logs in' do
  let!(:alice) { Fabricate(:alice) }

  scenario 'from the header' do
    visit root_path
    within('nav') { click_link 'Log In' }
    expect(page).to have_css('h3', text: 'Log In')
    expect(page).to have_field('Email')
    expect(page).to have_field('Password')
  end

  scenario 'with correct details' do
    log_in_with('alice@example.com', 'password')
    expect_to_be_logged_in_as('alice')
  end

  scenario 'with an email in a different letter case and surrounding spaces' do
    log_in_with(' Alice@Example.com ', 'password')
    expect_to_be_logged_in_as('alice')
  end

  scenario 'with a wrong password' do
    log_in_with('alice@example.com', 'wrong password')
    expect_log_in_error
  end

  scenario 'with an email that has no account' do
    log_in_with('bob@example.com', 'password')
    expect_log_in_error
  end

  scenario 'when already logged in' do
    log_in(alice)
    visit login_path
    expect(page).to have_current_path(home_path)
  end

  scenario 'visiting the home page when not logged in' do
    visit home_path
    expect(page).to have_current_path(login_path)
    expect(page).to have_content('You must be logged in to do that.')
  end

  scenario 'after too many attempts' do
    10.times { log_in_with('alice@example.com', 'wrong password') }
    log_in_with('alice@example.com', 'password')
    expect(page).to have_current_path(login_path)
    expect(page).to have_content('Try again later.')
    within('nav') { expect(page).to have_link('Log In') }
  end

  def log_in_with(email, password)
    visit login_path
    fill_in 'Email', with: email
    fill_in 'Password', with: password
    click_button 'Log In'
  end

  def expect_to_be_logged_in_as(username)
    expect(page).to have_current_path(home_path)
    expect(page).to have_content("Username: #{username}")
    within('nav') { expect(page).to have_button(username) }
  end

  def expect_log_in_error
    expect(page).to have_current_path(login_path)
    expect(page).to have_content('Log in error, please try again.')
  end
end
