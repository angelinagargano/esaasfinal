Given("I am on the Preferences page") do
  visit '/preferences'
end

Then("I should see the following options for Budget:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_select('budget', with_options: [option])
  end
end

Then("I should see the following options for Distance:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_select('distance', with_options: [option])
  end
end

Then("I should see the following options for Performance Type:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_select('performance_type', with_options: [option])
  end
end

When("I select {string} for {string}") do |value, field|
  select(value, from: field.downcase.gsub(' ', '_'))
end

When("I select multiple options for {string}: {string} and {string}") do |field, option1, option2|
  select(option1, from: field.downcase.gsub(' ', '_'))
  select(option2, from: field.downcase.gsub(' ', '_'))
end

When("I press {string}") do |button|
  click_button(button)
end

Then("I should be redirected to the Home page") do
  expect(current_path).to eq('/home')
end

Then("I should see events matching my selections on the Home feed") do
  # Implement matching logic based on selected preferences
  # Example: expect(page).to have_content("Ballet")
end

Then("I should see all available events without filtering") do
  expect(page).to have_css('.event-card', count: 20)
end

Then("I should see an error: {string}") do |message|
  expect(page).to have_content(message)
end

Then("I should see an alert: {string}") do |message|
  expect(page).to have_content(message)
end

When("I do not select any options") do
  # No action needed; leaving all select fields blank
end
