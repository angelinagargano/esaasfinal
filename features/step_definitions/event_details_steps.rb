Given("the following events exist:") do |table|
  table.hashes.each do |event|
    Event.create(
      name: event['Name'],
      venue: event['Venue'],
      date: event['Date'],
      time: event['Time'],
      style: event['Style'],
      location: event['Location'],
      price: event['Price'],
      description: event['Description'],
      tickets: event['Tickets']
    )
  end
end

Then("20 seed events should exist") do
  expect(Event.count).to eq(20)
end

When("I click on its event card") do
  find('.event-card', text: /Rennie Harris/).click
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

When("I click {string}") do |link_text|
  click_link(link_text)
end

Then("I should see a message: {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should be redirected to the ticket site") do
  # Assuming the link opens in same tab during test
  expect(current_url).to match(/https:\/\/shop\.joyce\.org/)
end

Then("the URL should contain {string}") do |url|
  expect(current_url).to include(url)
end
