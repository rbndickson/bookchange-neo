def log_in(user = nil)
  user ||= Fabricate(:user)
  visit login_path
  fill_in 'Email', with: user.email
  fill_in 'Password', with: user.password
  click_button 'Log In'
end

def expect_field_error(label, message)
  field = find_field(label)
  expect(field[:class]).to include('is-invalid')
  expect(page).to have_css("##{field[:id]} ~ .invalid-feedback", text: message)
end

def expect_no_horizontal_scrolling
  scroll_width = page.evaluate_script('document.documentElement.scrollWidth')
  client_width = page.evaluate_script('document.documentElement.clientWidth')
  expect(scroll_width).to be <= client_width
end
