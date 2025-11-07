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
#   expect(current_path).to eq(root_path)
# end

Then("I should see \"Welcome, %{name}\"", :wrapper) do |name|
  # fallback handled by later step if the exact step isn't used by features
  expect(page).to have_content("Welcome, #{name}")
end


Then("I should see \"Logged in as %{username}\"", :wrapper) do |username|
  expect(page).to have_content("Logged in as #{username}")
end

Then("I should be redirected to the Login page") do
    expect(current_path).to eq('/login')
end

Then("I should see an error message") do
  expect(page).to have_css('.alert')
end

Given(/an existing user with username "([^"]+)" and password "([^"]+)"/) do |username, password|
  User.create!(email: "#{username}@example.com", name: username.capitalize, username: username, password: password) unless User.exists?(username: username)
end
