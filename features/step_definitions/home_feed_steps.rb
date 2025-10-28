Given("I have not set any preferences") do
  # Clear any saved preferences by setting all to "No Preference"
  visit '/preferences'
  select 'No Preference', from: 'budget'
  select 'No Preference', from: 'distance'
  select 'No Preference', from: 'performance_type'
  click_button 'Save Preferences'
  visit '/' # Return to home page
end

Then("I should see all events") do
  expect(page).to have_css('.event-card', count: 20)
end

Given("I can select my preferences") do
  visit '/preferences'
  expect(page).to have_content('Set Your Preferences')
end

Given("I am on the Home page") do
  visit '/'
end

When("I complete the mini quiz with my budget, location, and performance type") do
  select '$30-50', from: 'budget'
  select 'Brooklyn', from: 'location'
  select 'Dance', from: 'performance_type'
end

And("I save my preferences") do
  click_button('Save Preferences')
end

Then("I should see events filtered based on my preferences") do
  # Implement filtered event check logic
end

When("I select a specific date or date range") do
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

Then("I should see the event name, date, time, location, price, description, and ticket link") do
  expect(page).to have_css('.event-name')
  expect(page).to have_css('.event-date')
  expect(page).to have_css('.event-time')
  expect(page).to have_css('.event-location')
  expect(page).to have_css('.event-price')
  expect(page).to have_css('.event-description')
  expect(page).to have_css('.event-ticket-link')
end

Given("{string} exists") do |event_name|
  # Create event with all required fields
  Event.create!(
    name: event_name,
    date: Date.parse('December 3, 2025'),
    time: '7:30 PM',
    location: 'BAM Brooklyn Academy of Music',
    price: 35,
    description: 'A captivating performance',
    ticket_link: 'https://tickets.bam.org'
  ) unless Event.exists?(name: event_name)
end

Then("I should see the following details on its event card:") do |table|
  table.rows_hash.each do |field, value|
    expect(page).to have_content(value)
  end
end
