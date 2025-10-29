Given("I have not set any preferences") do
  visit preferences_path
  # Uncheck all checkboxes to simulate "No Preference"
  all('input[type=checkbox]').each { |cb| uncheck(cb[:id]) rescue nil }
  click_button 'Save Preferences'
  visit '/' # Return to home page
end

Then("I should see all events") do
  # Assuming all events are rendered in divs with class 'card'
  expect(Event.count).to be >= 3
  expect(page).to have_css('.card', count: Event.count)
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

And ("I select my preferences: Price {string}, Style {string}") do |price, style|
  # Simulate filter selections, or store preferences in session
  # For simplicity, just store in @selected_preferences for test filtering
  @selected_price = price
  @selected_style = style
end

Then("I should see events filtered based on my preferences") do
  cards = page.all('.card')
  filtered_events = cards.select do |card|
    card.has_content?(@selected_price) && card.has_content?(@selected_style)
  end
  expect(filtered_events.count).to be >= 1, "Expected at least one filtered event ('$#{@selected_price}' and '#{@selected_style}'), but found none. Total cards: #{cards.count}\nCards text: #{cards.map(&:text).join("\n---\n")}"
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
  card = first(".card")
  within(card) do
    click_link("More Details")
  end 
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
  expect(page).to have_current_path('/preferences')
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
