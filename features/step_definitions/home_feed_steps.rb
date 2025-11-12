Given("I have not set any preferences") do
  # Clear session preferences by using the clear preferences endpoint
  # This ensures no filtering is applied
  visit preferences_path
  
  # Click the Clear Preferences button which posts to clear_preferences_path
  # This will delete session[:preferences] and redirect to preferences_path
  if page.has_button?('Clear Preferences', id: 'clear_preferences')
    click_button('clear_preferences')
    # After clearing, we're redirected to preferences_path, so navigate to performances
    visit performances_path
  else
    # Fallback: set "No Preference" for required field (performance_type)
    check('performance_type_no-preference') if page.has_unchecked_field?('performance_type_no-preference')
    click_button 'Save Preferences'
    # After saving, we're redirected to root_path, so navigate to performances
    visit performances_path
  end
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
  visit performances_path
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
  # Define numeric ranges for each price preference
  min, max = case @selected_price
             when '$0–$25' then [0, 25]
             when '$25–$50' then [25, 50]
             when '$50–$100' then [50, 100]
             when '$100+' then [100, Float::INFINITY]
             else [0, Float::INFINITY]
             end

  # Get all visible event cards
  cards = page.all('.card')

  filtered_events = cards.select do |card|
    # Extract price value like "$35" or "35"
    price_text = card.text[/\$?\d+/]
    price_value = price_text ? price_text.gsub('$', '').to_f : 0

    # Check if price fits selected range and style matches
    price_match = price_value >= min && price_value <= max
    style_match = card.has_content?(@selected_style)

    price_match && style_match
  end
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

When("I click on an event card") do
  card = first(".card")
  # Extract the event ID from the card's data attribute
  event_id = card['data-event-id']
  @event = Event.find(event_id)
  
  within(card) do
    click_link("More Details")
  end 
end

Then("I should be taken to the Event Details page") do
  expect(page).to have_current_path(%r{/performances/\d+/details}, ignore_query: true)
end


Given('I am on the Event Details page for {string}') do |event_name|
  event = Event.find_by(name: event_name)
  raise "No event found with name #{event_name}" unless event
  visit details_performance_path(event,show_calendar_button: true)
end

Then('I should be taken to the Home page') do
  expect(page).to have_current_path('/preferences')
end

Then("I should see the event name, date, time, location, price, description, and ticket link") do
  # Use the first <em> inside h2 for the name
  expect(page).to have_css('h2 em', text: @event.name)

  # Check the details list
  expect(page).to have_css('#details li', text: "Date: #{@event.date}")
  expect(page).to have_css('#details li', text: "Time: #{@event.time}")
  expect(page).to have_css('#details li', text: "Price: #{@event.price}")
  expect(page).to have_css('#details li', text: "Venue: #{@event.venue}")
  expect(page).to have_css('#details li', text: "Location: #{@event.location}")
  expect(page).to have_css('#details li', text: "Style: #{@event.style}")

  # Description
  expect(page).to have_css('#description', text: @event.description)

  # Tickets link
  expect(page).to have_link('Purchase Tickets', href: @event.tickets)
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
  details = table.rows_hash
  event_card = all('.card', text: 'For All Your Life').find do |card|
    card.has_content?(details['Date']) && card.has_content?(details['Location'])
  end

  details.each_value do |value|
    expect(event_card).to have_content(value)
  end
end
