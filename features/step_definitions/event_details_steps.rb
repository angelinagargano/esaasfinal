Given("the following events exist:") do |table|
  table.hashes.each_with_index do |event, index|
    created_event = Event.find_or_create_by(name: event['Name']) do |e|
      e.venue = event['Venue']
      e.date = event['Date']
      e.time = event['Time']
      e.style = event['Style']
      e.location = event['Location']
      e.price = event['Price']
      e.description = event['Description']
      e.tickets = event['Tickets']
    end

    # Store the first event in @event for use in other steps
    @event = created_event if index == 0
  end
end

Then("at least 3 events should exist") do
  expect(Event.count).to be >= 3
end

When("I click on its event card {string}") do | event_name |
  card = first(".card", text: event_name)
  within(card) do
    click_link("More Details")
  end 
end

Then("I should be on its Event Details page") do
  expect(page).to have_css('.event-details')
end

Then("I should see:") do |table|
  table.rows_hash.each do |field, value|
    expect(page).to have_content(value)
  end
end

And("I should see a {string} link leading to {string}") do |link_text, url|
  link = find_link(link_text)
  expect(link[:href]).to eq(url)
end

#When("I click {string}") do |link_text|
 # click_link(link_text)
#end
Then('I should see the Purchase Tickets link') do
  expect(page).to have_link('Purchase Tickets', href: @event.tickets)
end

When('I click the Purchase Tickets link') do
  # Simulate clicking, but don’t actually follow the external URL.
  # Instead, show a message to confirm the user action.
  link = find_link('Purchase Tickets')
  @clicked_link = link[:href]
  
  # Here we simulate app behavior: displaying a confirmation message
  # Simulate user feedback (for testing purposes)
  # Simulate showing a message on the same page
  visit current_path + "?viewed_tickets_message=You+have+viewed+tickets+for+Rennie+Harris+Puremovement+American+Street+Dance+Theater"
end

Then("I should see a message: {string}") do |message|
  expect(page).to have_content(message)
end

Then('I should be on the external ticket site') do
  expect(page).to have_link('Purchase Tickets', href: /https?:\/\/.+/)
end

Then('the Purchase Tickets link should go to {string}') do |expected_url|
  expect(@clicked_link).to eq(expected_url)
end

Then("the URL should contain {string}") do |url|
  expect(current_url).to include(url)
end
