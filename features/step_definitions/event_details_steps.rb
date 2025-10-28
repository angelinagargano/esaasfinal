Given("the following events exist:") do |table|
  table.hashes.each do |event|
    Event.find_or_create_by(name: event['Name']) do |e|
      e.venue = event['Venue']
      e.date = event['Date']
      e.time = event['Time']
      e.style = event['Style']
      e.location = event['Location']
      e.price = event['Price']
      e.description = event['Description']
      e.tickets = event['Tickets']
    end
  end
end

Then("at least 3 events should exist") do
  expect(Event.count).to eq(3)
end

When("I click on its event card") do
  find('#events .card', text: /Rennie Harris/).click
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
