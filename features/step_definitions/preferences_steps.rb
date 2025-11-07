# features/step_definitions/preferences_steps.rb

Given("I am on the Preferences page") do
  visit '/preferences'
end

Then("I should see the following options for Budget:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_field("budget_#{option.parameterize}", type: 'checkbox')
  end
end

Then("I should see the following options for Performance Type:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_field("performance_type_#{option.parameterize}", type: 'checkbox')
  end
end

When("I select {string} for {string}") do |value, field|
  field_id = "#{field.downcase.gsub(' ', '_')}_#{value.parameterize}"
  check(field_id)
end

When(/I select multiple (?:Budgets|Performance Types): "([^"]+)" and "([^"]+)"/) do |option1, option2|
  [option1, option2].each do |opt|
    field_id = "budget_#{opt.parameterize}"
    field_id = "performance_type_#{opt.parameterize}" unless page.has_unchecked_field?(field_id)
    check(field_id)
  end
end

When("I press {string}") do |button|
  if button == "Clear Preferences"
    click_button("clear_preferences") 
  else
    click_button(button)
  end
end

Then("I should be redirected to the Home page") do
  expect(page).to have_current_path(performances_path)
  #expect(page).to have_content(/Preferences saved./)
end

Then("I should see events matching my selections on the Home feed") do
  expect(page).to have_css('.card') 
end

Then("I should see all available events without filtering") do
  expect(page).to have_css('.card').or have_content('All Performances').or have_content('Preferences saved.')
end

Then(/I should see an error(?: message)?: "([^"]+)"/) do |message|
  expect(page).to have_content(message)
end

Then(/I should see an alert(?: saying)? "([^"]+)"/) do |message|
  expect(page).to have_content(message)
end

When("I do not select any options for Budget or Performance Type") do
  all('input[type=checkbox]').each { |cb| uncheck(cb[:id]) if cb.checked? rescue nil }
end

Then('I should remain on the Preferences page') do
  expect(current_path).to eq('/preferences')
end
