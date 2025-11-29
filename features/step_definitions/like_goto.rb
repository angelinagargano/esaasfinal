Given("I am not marked as going to {string}") do |event_name|
  event = Event.find_by(name: event_name)
  user = User.find_by(username: 'Alice')
  user.going_events_list.delete(event)
  user.save!
end
When('I click the {string} button on the {string} event card') do |button_text, event_name|
  event = Event.find_by(name: event_name)
  within(find('.card', text: event_name)) do
    btn = find('button.btn-heart')
    if button_text == "Like"
      btn.click if btn[:title] == "Like"
      # Wait for AJAX to complete - button should change to "Unlike"
      expect(page).to have_css("button.btn-heart[title='Unlike']", wait: 5)
    elsif button_text == "Unlike"
      btn.click if btn[:title] == "Unlike"
      # Wait for AJAX to complete - button should change to "Like"
      expect(page).to have_css("button.btn-heart[title='Like']", wait: 5)
      # Wait for database to reflect the change - check Like model directly
      user = @logged_in_user || User.find_by(username: "Alice")
      require 'timeout'
      Timeout.timeout(5) do
        loop do
          user.reload
          # Check the Like model directly instead of the association to avoid caching issues
          break unless Like.exists?(user: user, event: event)
          sleep(0.1)
        end
      end
    end
  end
end
Then('{string} should appear in my liked events list') do |event_name|
  visit liked_events_performances_path
  expect(page).to have_content(event_name)
end
Then('{string} should not be in my liked events list') do |event_name|
  visit liked_events_performances_path
  expect(page).not_to have_content(event_name, wait: 5)
end
When('I click Going to button') do 
  if page.has_button?('Going to')
    click_button 'Going to'
  else
    puts "User is already marked as going — button not present"
  end
end
Then('I should be going to event') do 
  expect(page).to have_content("You're going!")
end
Then('I should see {string} button') do |button_text|
  expect(page).to have_button(button_text)
end

When('I visit the liked events page') do
  visit liked_events_performances_path
end

Then('I should see an empty liked events list') do
  has_message = page.has_content?(/no.*liked|haven't.*liked|empty/i)
  has_no_cards = !page.has_css?('.card', minimum: 1)
  expect(has_message || has_no_cards).to be true
end