# features/step_definitions/user_profile_steps.rb

Given("I am on the User Profile page") do
  visit user_profile_path(@user)
end

Given("I am on the User Edit page") do
  visit edit_user_path(@user)
end

# When("I press {string}") do |button_text|
#   click_button(button_text)
# end

# When("I click {string}") do |link_text|
#   click_link(link_text)
# end

When("I change Username to {string}") do |new_username|
  fill_in "username", with: new_username
end

When("I change Password to {string}") do |new_password|
  fill_in "password", with: new_password
  fill_in "password_confirmation", with: new_password
end

When("I change Name to {string}") do |new_name|
  fill_in "name", with: new_name
end

When("I change Email to {string}") do |new_email|
  fill_in "email", with: new_email
end

Then("I should be on the User Edit page") do
  expect(page).to have_current_path(edit_user_path(@user))
end

Then("I should be redirected to the User Profile page") do
  expect(page).to have_current_path(user_profile_path(@user))
end

Then("I should see my username, name, and email") do
  expect(page).to have_content(@user.username)
  expect(page).to have_content(@user.name)
  expect(page).to have_content(@user.email)
end

Then('I should see "Are you sure you want to change your password?"') do
  expect(page).to have_content("Are you sure you want to change your password?")
end

Then("I should see a list of my liked events in chronological order") do
  liked_events = @user.liked_events.order(:date)
  liked_events.each_cons(2) do |a, b|
    expect(page.body.index(a.name)).to be < page.body.index(b.name)
  end
end

# Then("I should see a list of events that I am going to in chronological order") do
#   going_events = @user.going_events.order(:date)
#   going_events.each_cons(2) do |a, b|
#     expect(page.body.index(a.name)).to be < page.body.index(b.name)
#   end
# end

When("I click on an event card in the liked events list") do
  first(".liked-events .event-card").click
end

# When("I click on an event card in the going to events list") do
#   first(".going-events .event-card").click
# end

Then("I should be redirected to the Event Details page for that event") do
  expect(page).to have_current_path(/\/events\/\d+/)
  expect(page).to have_content("Event Details")
end
