 When('I click the {string} button on the {string} event card') do |button_text, event_name|
  event_card = find('.event-card', text: event_name)
  within(event_card) do
    click_button(button_text)
  end
end
Then('{string} should appear in my liked events list') do |event_name|
  visit liked_events_path
  expect(page).to have_content(event_name)
end
Then('{string} should not be in my liked events list') do |event_name|
  visit liked_events_path
  expect(page).not_to have_content(event_name)
end

#When('I click the {string} button') do |button_text|
#  click_button(button_text)
#end
Then('{string} should be added to my Google Calendar') do |event_name|
  event = Event.find_by(name: event_name)
  expect(event.added_to_google_calendar?).to be true
end
