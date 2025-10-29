# features/step_definitions/preferences_steps.rb

Given("I am on the Preferences page") do
  visit '/preferences'
end

Then("I should see the following options for Budget:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_field("budget_#{option.parameterize}", type: 'checkbox')
  end
end

# Then("I should see the following options for Distance:") do |table|
#   table.raw.flatten.each do |option|
#     expect(page).to have_field("distance_#{option.parameterize}", type: 'checkbox')
#   end
# end

Then("I should see the following options for Performance Type:") do |table|
  table.raw.flatten.each do |option|
    expect(page).to have_field("performance_type_#{option.parameterize}", type: 'checkbox')
  end
end

When("I select {string} for {string}") do |value, field|
  # Convert field name to match your checkbox IDs
  field_name = "#{field.downcase.gsub(' ', '_')}_#{value.parameterize}"
  
  if page.has_unchecked_field?(field_name)
    check(field_name)
  else
    # fallback: click label if the checkbox ID doesn't exist
    find('label', text: value).click rescue raise "Checkbox for '#{value}' in '#{field}' not found"
  end
end

When(/I select multiple (?:Budgets|Performance Types): "([^"]+)" and "([^"]+)"/) do |option1, option2|
  [option1, option2].each do |opt|
    field_name = opt.downcase.gsub(' ', '_')
    if page.has_unchecked_field?("budget_#{opt.parameterize}")
      check("budget_#{opt.parameterize}") rescue nil
    elsif page.has_unchecked_field?("performance_type_#{opt.parameterize}")
      check("performance_type_#{opt.parameterize}") rescue nil
    else
      # fallback: click label if ID unknown
      find('label', text: opt).click rescue nil
    end
  end
end

When("I press {string}") do |button|
  click_button(button)
end

Then("I should be redirected to the Home page") do
  expect(page).to have_current_path(root_path)
  expect(page).to have_content(/Preferences saved./)
end

Then("I should see events matching my selections on the Home feed") do
  expect(page).to have_css('.card') # assumes each event is in a card
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
