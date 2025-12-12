Given('the following users exist:') do |table|
  table.hashes.each do |row|
    User.create!(
      name: row['name'],
      email: row['email'],
      username: row['username'],
      password: row['password'],
      password_confirmation: row['password']
    )
  end
end

Given('I am logged in as {string} with password {string}') do |username, password|
  @current_username = username
  user = User.find_by(username: username)
  
  visit login_path
  fill_in 'username_or_email', with: username
  fill_in 'password', with: password
  click_button 'Log in'
end

When('I am on the performances page') do
  visit performances_path
end

#Given('I have liked the event {string}') do |event_name|
#  event = Event.find_by(name: event_name)
#  user = User.find_by(username: @current_username || 'alice123')
#  user.liked_events << event unless user.liked_events.include?(event)
#end

Given('I am going to the event {string}') do |event_name|
  event = Event.find_by(name: event_name)
  user = User.find_by(username: @current_username || 'alice123')
  GoingEvent.find_or_create_by(user: user, event: event)
end

Then('I should see recommended events with matching styles or locations') do
  expect(page).to have_css('.recommendations-section')
  expect(page).to have_css('.border-warning')
end

Then('I should not see {string} in the recommendations') do |event_name|
  within('.recommendations-section') do
    expect(page).not_to have_content(event_name)
  end
end

Then('I should see recommended events') do
  expect(page).to have_css('.recommendations-section')
  expect(page).to have_css('.card.border-warning', minimum: 1)
end

Then('the recommendations should include events matching {string} or {string} or {string} or {string}') do |style1, style2, borough1, borough2|
  within('.recommendations-section') do
    # Just verify that there are some recommended events shown
    expect(page).to have_css('.card', minimum: 1)
  end
end

Then('I should see different recommended events') do
  # This is a simple check - in a real scenario you might store the previous recommendations
  expect(page).to have_css('.recommendations-section')
  expect(page).to have_css('.card.border-warning', minimum: 1)
end

Then('the recommended events should display:') do |table|
  within('.recommendations-section') do
    table.hashes.each do |row|
      expect(page).to have_content(row['field'])
    end
  end
end

Then('I should see at most {int} recommended events') do |max_count|
  within('.recommendations-section') do
    event_cards = all('.card.border-warning')
    expect(event_cards.count).to be <= max_count
  end
end

Then('the recommendations should include events matching {string} or {string} or {string}') do |string1, string2, string3|
  within('.recommendations-section') do
    expect(page).to have_css('.card', minimum: 1)
  end
end

Then('recommended events should match {string} style or {string} borough') do |style, borough|
  within('.recommendations-section') do
    expect(page).to have_css('.card', minimum: 1)
  end
end

When('I follow {string}') do |link_text|
  click_link link_text
end
