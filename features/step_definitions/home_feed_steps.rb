Given("I have not set any preferences") do
  # Clear any saved preferences
  visit '/preferences'
  click_button('Clear Preferences') if page.has_button?('Clear Preferences')
end

Then("I should see all events") do
  expect(page).to have_css('.event-card', count: 20)
end

When("I complete the mini quiz with my budget, vibe, and location") do
  # Assume these values are already selected in previous steps
end

And("I save my preferences") do
  click_button('Save Preferences')
end

Then("I should see events filtered based on my preferences") do
  # Implement filtered event check logic
end

When("I select a date or date range") do
  fill_in 'date_filter', with: 'December 3, 2025'
  click_button 'Apply Filter'
end

Then("I should see only events within that range") do
  expect(page).to have_content('December 3, 2025')
end

When("I click on the event card") do
  find('.event-card', match: :first).click
end

Then("I should be taken to the Event Details page") do
  expect(page).to have_current_path(/\/events\/\d+/)
end

Then("I should see the event name, date, time, location, and price") do
  expect(page).to have_css('.event-name')
  expect(page).to have_css('.event-date')
  expect(page).to have_css('.event-time')
  expect(page).to have_css('.event-location')
  expect(page).to have_css('.event-price')
end

Given("{string} exists") do |event_name|
  # Seed event in test DB if needed
  Event.create(name: event_name) unless Event.exists?(name: event_name)
end

Then("I should see on its card:") do |table|
  table.rows_hash.each do |field, value|
    expect(page).to have_content(value)
  end
end
