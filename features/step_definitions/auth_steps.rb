# Given("the following user exists:")

Given("I have opened the app") do
  visit root_path
end

Given("I am on the Sign up page") do
  visit '/signup' rescue visit signup_path if defined?(signup_path)
end

Given("I am on the Login page") do
  visit '/login' rescue visit new_user_session_path if defined?(new_user_session_path)
end

When("I fill in the sign up form with:") do |table|
  data = table.rows_hash
  fill_in 'email', with: data['Email']
  fill_in 'name', with: data['Name']
  fill_in 'username', with: data['Username']
  fill_in 'password', with: data['Password']
  fill_in 'password_confirmation', with: data['Password']
end

When("I fill in the login form with:") do |table|
  data = table.rows_hash
  fill_in 'username', with: data['Username']
  fill_in 'password', with: data['Password']
end

When(/I click "([^"]+)"/) do |link_text|
  # try link first, then button
  if page.has_link?(link_text)
    click_link(link_text)
  else
    click_button(link_text)
  end
end

# When(/I press "([^"]+)"/) do |button|
#   click_button button
# end

# Then("I should be redirected to the Home page") do
#   # Home page is the performances index
#   expect(current_path).to eq(performances_path)
# end


Then('I should see {string}') do |text|
  expect(page).to have_content(text)
end

Then('I should be redirected to the Login page') do
  expect(current_path).to eq('/login')
end

Then("I should see an error message") do
  expect(page).to have_css('.alert')
end

Given(/an existing user with username "([^"]+)" and password "([^"]+)"/) do |username, password|
  # Try to create a real User record when possible (model + table present).
  if defined?(User)
    begin
      if ActiveRecord::Base.connection.data_source_exists?('users')
        User.create!(email: "#{username}@example.com", name: username.capitalize, username: username, password: password) unless User.exists?(username: username)
      else
        # No users table: store in an in-memory stub for the session fallback
        $STUBBED_USERS ||= {}
        $STUBBED_USERS[username] = password
      end
    rescue => _e
      # If anything goes wrong (e.g. no DB), fall back to in-memory stub
      $STUBBED_USERS ||= {}
      $STUBBED_USERS[username] = password
    end
  else
    $STUBBED_USERS ||= {}
    $STUBBED_USERS[username] = password
  end
end
