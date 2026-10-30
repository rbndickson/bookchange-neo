require 'rails_helper'

feature 'user cannot change another account' do
  let(:alice) { Fabricate(:alice) }

  context 'when not logged in' do
    scenario 'visits the Update Account page' do
      visit edit_user_path(alice)
      expect_to_be_asked_to_log_in
    end

    scenario 'submits a change to an account' do
      page.driver.submit :patch, user_path(alice), user: { username: 'taken' }
      expect_to_be_asked_to_log_in
      expect(alice.reload.username).to eq('alice')
    end

    scenario 'visits the Change Password page' do
      visit edit_password_path
      expect_to_be_asked_to_log_in
    end

    scenario 'submits a password change' do
      page.driver.submit :patch, password_path, {}
      expect_to_be_asked_to_log_in
    end
  end

  context 'when logged in as another user' do
    before { log_in(Fabricate(:bob)) }

    scenario "visits another user's Update Account page" do
      visit edit_user_path(alice)
      expect_access_denied
    end

    scenario "submits a change to another user's account" do
      page.driver.submit :patch, user_path(alice), user: { username: 'taken' }
      expect_access_denied
      expect(alice.reload.username).to eq('alice')
    end

    scenario 'visits the Update Account page of an account that does not exist' do
      visit edit_user_path(id: 0)
      expect_access_denied
    end
  end

  def expect_to_be_asked_to_log_in
    expect(page).to have_current_path(login_path)
    expect(page).to have_content('You must be logged in to do that.')
  end

  def expect_access_denied
    expect(page).to have_current_path(home_path)
    expect(page).to have_content('You do not have access.')
  end
end
