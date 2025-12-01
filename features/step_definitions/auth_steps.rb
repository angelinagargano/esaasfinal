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

Given("I am logged in as {string}") do |username|
  @logged_in_user = User.find_or_create_by!(username: username) do |u|
    u.email = "#{username}@example.com"
    u.name = username.capitalize
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  unless @logged_in_user.authenticate("password123")
    @logged_in_user.update!(password: "password123", password_confirmation: "password123")
  end

  visit login_path
  find('input[name="username_or_email"]').set(@logged_in_user.username)
  find('input[name="password"]').set("password123")
  click_button "Log in"

  expect(page).to have_content("Logged in as")
end

When("I fill in the sign up form with:") do |table|
  data = table.rows_hash
  find('input[name="user[email]"]').set(data['Email'])
  find('input[name="user[name]"]').set(data['Name'])
  find('input[name="user[username]"]').set(data['Username'])
  find('input[name="user[password]"]').set(data['Password'])
  find('input[name="user[password_confirmation]"]').set(data['Confirm Password'])
end

When("I fill in the login form with:") do |table|
  data = table.rows_hash
  username_or_email = data['Username or Email'] || data['Username'] || data['Email']
  find('input[name="username_or_email"]').set(username_or_email)
  find('input[name="password"]').set(data['Password'])
end

When("I fill in {string} with {string}") do |field, value|
  if field == "Content"
    fill_in 'group_message[content]', with: value rescue fill_in 'message[content]', with: value rescue fill_in 'content', with: value
  elsif field == "Message"
    fill_in 'message', with: value rescue fill_in 'message[content]', with: value
  elsif field == "Name"
    # Try multiple ways to find the Name field (for group forms)
    fill_in 'group[name]', with: value rescue fill_in 'Name', with: value rescue find('input[name="group[name]"]').set(value)
  elsif field == "Description"
    # Try multiple ways to find the Description field (for group forms)
    fill_in 'group[description]', with: value rescue fill_in 'Description', with: value rescue find('textarea[name="group[description]"]').set(value)
  else
    fill_in field, with: value
  end
end

When(/I click "([^"]+)" on the (\w+) page/) do |link_text, page_name|
  if page.has_link?(link_text)
    click_link(link_text)
  else
    click_button(link_text)
  end
end

When("I click {string}") do |link_text|
  if page.has_link?(link_text)
    click_link(link_text)
  elsif page.has_button?(link_text)
    click_button(link_text)
  else
    raise "Could not find link or button with text '#{link_text}'"
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

Then("I should not see {string}") do |text|
  expect(page).not_to have_content(text)
end

Then('I should be redirected to the Login page') do
  expect(current_path).to eq('/login')
end

Then("I should see an error message") do
  expect(page).to have_css('.alert')
end

When(/^I click "Logout" or "Log out"$/) do
  if page.has_link?('Logout')
    click_link('Logout')
  elsif page.has_link?('Log out')
    click_link('Log out')
  elsif page.has_button?('Logout')
    click_button('Logout')
  elsif page.has_button?('Log out')
    click_button('Log out')
  else
    # Fallback: submit DELETE request to logout path
    page.driver.submit :delete, logout_path, {}
  end
end

Then("I should be redirected to the root page") do
  expect(current_path).to eq(root_path)
end

When("I try to access the Conversations page") do
  visit conversations_path
end

Given(/an existing user with username "([^"]+)" and password "([^"]+)"/) do |username, password|
  if defined?(User)
    begin
      if ActiveRecord::Base.connection.data_source_exists?('users')
        User.create!(
          email: "#{username}@example.com", 
          name: username.capitalize, 
          username: username, 
          password: password,
          password_confirmation: password
        ) unless User.exists?(username: username)
      else
        $STUBBED_USERS ||= {}
        $STUBBED_USERS[username] = password
      end
    rescue => _e
      $STUBBED_USERS ||= {}
      $STUBBED_USERS[username] = password
    end
  else
    $STUBBED_USERS ||= {}
    $STUBBED_USERS[username] = password
  end
end
