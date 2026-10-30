require 'rails_helper'

feature 'visitor views the front page' do
  scenario 'with its introduction and Sign Up button' do
    visit root_path
    within('main') do
      expect(page).to have_css('h1', text: 'Exchange books you have read for something new.')
      expect(page).to have_content('Save space in your home and help the environment without giving up paper books.')
      expect(page).to have_link('Sign Up', href: signup_path)
    end
    expect(page).to have_title('Bookchange')
  end

  scenario 'with the visitor header' do
    visit root_path
    within('nav') do
      expect(page).to have_link('Bookchange', href: root_path)
      expect(page).to have_link('Sign Up', href: signup_path)
      expect(page).to have_link('Log In', href: login_path)
    end
  end

  scenario 'with the logged-in header' do
    log_in(Fabricate(:alice))
    visit root_path
    within('nav') do
      expect(page).to have_link('Bookchange', href: home_path)
      expect(page).to have_button('alice')
      expect(page).to have_button('Log Out', visible: :all)
      expect(page).to have_no_link('Log In')
    end
  end

  scenario 'on a phone-sized screen', :js do
    page.driver.resize(375, 800)
    [root_path, signup_path, login_path].each do |path|
      visit path
      expect_no_horizontal_scrolling
    end
    log_in(Fabricate(:alice))
    expect_no_horizontal_scrolling
    within('nav') { click_button 'alice' }
    expect(page).to have_button('Log Out')
  end

  scenario 'and closes a message', :js do
    visit home_path
    expect(page).to have_content('You must be logged in to do that.')
    find('.alert .btn-close').click
    expect(page).to have_no_content('You must be logged in to do that.')
  end
end
