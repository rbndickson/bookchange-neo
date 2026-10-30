require 'rails_helper'

feature 'user logs out', :js do
  before { log_in(Fabricate(:alice)) }

  scenario 'the user menu shows the username and Log Out' do
    open_user_menu
    expect(page).to have_button('Log Out')
  end

  scenario 'from the user menu' do
    log_out
    expect(page).to have_current_path(root_path)
    expect(page).to have_content('You have logged out.')
    within('nav') do
      expect(page).to have_link('Sign Up')
      expect(page).to have_link('Log In')
    end
  end

  scenario 'and then visits the home page' do
    log_out
    expect(page).to have_content('You have logged out.')
    visit home_path
    expect(page).to have_current_path(login_path)
    expect(page).to have_content('You must be logged in to do that.')
  end

  def open_user_menu
    within('nav') { click_button 'alice' }
  end

  def log_out
    open_user_menu
    click_button 'Log Out'
  end
end
