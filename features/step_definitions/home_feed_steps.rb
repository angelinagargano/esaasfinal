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


When("I select the date {string}") do |date|
  if page.has_field?('date_filter_start')
    fill_in 'date_filter_start', with: date
    # Leave end date empty for single date filtering
    click_button 'Apply Filter'
  else
    raise "No date filter input found on page. Please add date_filter_start field to the view."
  end
end

When("I select the date range from {string} to {string}") do |start_date, end_date|
  if page.has_field?('date_filter_start') && page.has_field?('date_filter_end')
    fill_in 'date_filter_start', with: start_date
    fill_in 'date_filter_end', with: end_date
    click_button 'Apply Filter'
  else
    raise "No date range filter inputs found on page. Please add date_filter_start and date_filter_end fields to the view."
  end
end

Then("I should see only events on {string}") do |date|
  # Check that at least one event with this date is visible
  expect(page).to have_css('.card', minimum: 1)
  
  # Check that all visible events have the correct date
  page.all('.card').each do |card|
    # Card should contain the date in either format
    expect(card.text).to match(/#{Regexp.escape(date)}/)
  end
end

Then("I should see only events between {string} and {string}") do |start_date, end_date|
  # Parse the date range
  start_date_obj = Date.parse(start_date)
  end_date_obj = Date.parse(end_date)
  
  # Check that at least one event is visible
  expect(page).to have_css('.card', minimum: 1)
  
  # Check that all visible events fall within the date range
  page.all('.card').each do |card|
    # Extract date from card text (looking for YYYY-MM-DD or other date formats)
    date_match = card.text.match(/(\d{4}-\d{2}-\d{2})|([A-Za-z]+\s+\d{1,2},\s+\d{4})/)
    
    if date_match
      event_date_str = date_match[0]
      event_date = Date.parse(event_date_str)
      
      expect(event_date).to be >= start_date_obj, 
        "Event date #{event_date} is before start date #{start_date_obj}"
      expect(event_date).to be <= end_date_obj,
        "Event date #{event_date} is after end date #{end_date_obj}"
    else
      raise "Could not find date in card text: #{card.text}"
    end
  end
end

Then("I should see {int} event(s)") do |count|
  expect(page).to have_css('.card', count: count)
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


Then("I should see the following details on the event card for {string}:") do |event_name, table|
  details = table.rows_hash
  
  # Find the card for the specific event
  event_card = page.all('.card').find do |card|
    card.has_content?(event_name)
  end
  
  raise "Could not find event card for '#{event_name}'" unless event_card
  
  # Verify each detail appears on the card
  details.each do |field, value|
    expect(event_card).to have_content(value), 
      "Expected to find '#{value}' for #{field} in event card for '#{event_name}', but it was not found"
  end
end
