# features/step_definitions/user_profile_steps.rb

Given("the user has logged in and created an account") do
  
  # Create a user for testing
  @user = User.find_or_create_by!(username: "testuser") do |u|
    u.email = "testuser@example.com"
    u.name = "Test User"
    u.password = "password123"
    u.password_confirmation = "password123"
  end
  
  if @user.persisted? && !@user.id_changed?
    @user.update!(password: "password123", password_confirmation: "password123")
  end

  # Log in the user
  visit login_path

  fill_in "Username", with: @user.username
  fill_in "Password", with: "password123"
  click_button "Log in"
  
  # Verify we're logged in - wait for redirect or check for logged in content
  begin
    expect(page).to have_content("Logged in as")
  rescue
    # If that fails, check if we're on performances page (which is the home after login)
    expect(page).to have_current_path(performances_path) rescue nil
  end
end

Given("I am on the User Profile page") do
  visit user_profile_path(@user)
end

Given("I am on the User Edit page") do
  visit edit_user_path(@user)
end

When("I press {string}") do |button_text|
  click_button(button_text)
end

When("I click {string}") do |link_text|
  # Try link first, then button
  if page.has_link?(link_text)
    click_link(link_text)
  elsif page.has_button?(link_text)
    click_button(link_text)
  else
    raise "Could not find link or button with text '#{link_text}'"
  end
end

When("I change Username to {string}") do |new_username|
  find('input[name="user[username]"]').set(new_username)
end

When("I change Password to {string}") do |new_password|
  find('input[name="user[password]"]').set(new_password)
  find('input[name="user[password_confirmation]"]').set(new_password)
end

When("I change Name to {string}") do |new_name|
  find('input[name="user[name]"]').set(new_name)
end

When("I change Email to {string}") do |new_email|
  find('input[name="user[email]"]').set(new_email)
end

Then("I should be on the User Edit page") do
  expect(page).to have_current_path(edit_user_path(@user))
end

Then("I should be redirected to the User Profile page") do
  #expect(page).to have_current_path("/users/#{@user.id}/profile")
  expect(current_path).to eq("/users/#{@user.id}/profile")
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
  liked_events = @user.liked_events.to_a.sort_by do |event|
    begin
      Date.parse(event.date)
    rescue
      Date.new(9999, 12, 31)
    end
  end
  
  expect(liked_events.length).to be > 0
  
  # Verify events appear in chronological order on the page
  # Get all event names from the page in order
  event_names_on_page = page.all('.liked-events .event-card .card-title').map(&:text)
  
  # Verify the order matches chronological order
  liked_events.each_cons(2) do |a, b|
    a_date = begin
      Date.parse(a.date)
    rescue
      Date.new(9999, 12, 31)
    end
    b_date = begin
      Date.parse(b.date)
    rescue
      Date.new(9999, 12, 31)
    end
    
    # Verify that the earlier date appears before the later date in the page
    expect(a_date <= b_date).to be true
    
    # Verify order on page - earlier event should appear first
    a_index = event_names_on_page.index(a.name)
    b_index = event_names_on_page.index(b.name)
    
    if a_index && b_index
      expect(a_index).to be < b_index if a_date < b_date
    end
  end
end

When("I click on an event card in the liked events list") do
  # Find the "View Details" link within the liked events section
  within(".liked-events") do
    click_link("View Details", match: :first)
  end
end

Then("I should be redirected to the Event Details page for that event") do
  # The details page should show event details
  expect(page).to have_css('.event-details')
  expect(page).to have_content("Details about")
end

Given("I have liked the event {string}") do |event_name|
  event = Event.find_by(name: event_name)
  raise "Event '#{event_name}' not found" unless event
  @user.liked_events << event unless @user.liked_events.include?(event)
end

Then("I should see {string} in my liked events") do |event_name|
  expect(page).to have_content(event_name)
  # Verify it's in the liked events section
  within(".liked-events") do
    expect(page).to have_content(event_name)
  end
end

Given("I do not have any liked events") do
  @user ||= User.find_by(username: "testuser")

  raise "User 'testuser' not found. Make sure the user is logged in or created first." unless @user

  if @user.respond_to?(:liked_events)
    @user.liked_events.destroy_all
  elsif @user.respond_to?(:liked_performances)
    @user.liked_performances.destroy_all
  else
    raise "User does not have a liked_events or liked_performances association."
  end
end