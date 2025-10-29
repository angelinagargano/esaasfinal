Given("I have not set any preferences") do
  visit preferences_path
  # Uncheck all checkboxes to simulate "No Preference"
  all('input[type=checkbox]').each { |cb| uncheck(cb[:id]) rescue nil }
  click_button 'Save Preferences'
  visit '/' # Return to home page
end

Then("I should see all events") do
  # Assuming all events are rendered in divs with class 'event-card'
  expect(page).to have_css('.event-card', minimum: 1)
end

Given("I can select my preferences") do
  visit '/preferences'
  expect(page).to have_content('Set Your Preferences')
end

Given("I am on the Home page") do
  visit '/'
end

When("I complete the mini quiz with my budget and performance type") do
  check('$25–$50') if page.has_unchecked_field?('$25–$50')
  check('Dance Theater') if page.has_unchecked_field?('Dance Theater')
end

And("I save my preferences") do
  click_button('Save Preferences')
end

Then("I should see events filtered based on my preferences") do
  # Expect at least one event matches the selections
  filtered_events = page.all('.event-card').select do |card|
    card.has_content?('$25–$50') && card.has_content?('Dance Theater')
  end
  expect(filtered_events.count).to be >= 1
end

When("I select a specific date or date range") do
  # Replace with actual date input id/class
  if page.has_field?('date_filter')
    fill_in 'date_filter', with: 'December 3, 2025'
    click_button 'Apply Filter'
  else
    warn "No date filter input found on page."
  end
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

Given('I am on the Event Details page for {string}') do |event_name|
  event = Event.find_by(name: event_name)
  raise "No event found with name #{event_name}" unless event
  visit details_performance_path(event)
end

Then('I should be taken to the Home page') do
  expect(page).to have_current_path('/')
end

Then("I should see the event name, date, time, location, price, description, and ticket link") do
  expect(page).to have_css('.card-title')
  expect(page).to have_content(/Date:/)
  expect(page).to have_content(/Time:/)
  expect(page).to have_content(/Location:/)
  expect(page).to have_content(/Price:/)
  expect(page).to have_content(/Description:/)
  expect(page).to have_link('Tickets', href: /https?:\/\//)
end

Given("{string} exists") do |event_name|
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
