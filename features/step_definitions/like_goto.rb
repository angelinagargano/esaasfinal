Given("I am not marked as going to {string}") do |event_name|
  event = Event.find_by(name: event_name)
  user = User.find_by(username: 'Alice')
  user.going_events_list.delete(event)
  user.save!
end
When('I click the {string} button on the {string} event card') do |button_text, event_name|
  within(find('.card', text: event_name)) do
    btn = find('button.btn-heart')
    if button_text == "Like"
      btn.click if btn[:title] == "Like"
    elsif button_text == "Unlike"
      btn.click if btn[:title] == "Unlike"
    end
  end
end
Then('{string} should appear in my liked events list') do |event_name|
  visit liked_events_performances_path
  expect(page).to have_content(event_name)
end
Then('{string} should not be in my liked events list') do |event_name|
  visit liked_events_performances_path
  expect(page).not_to have_content(event_name, wait: 5)
end
When('I click Going to button') do 
  if page.has_button?('Going to')
    click_button 'Going to'
  else
    puts "User is already marked as going — button not present"
  end
end
Then('I should be going to event') do 
  expect(page).to have_content("You're going!")
end
Then('I should see {string} button') do |button_text|
  expect(page).to have_button(button_text)
end