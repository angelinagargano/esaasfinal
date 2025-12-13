# features/step_definitions/external_sharing_steps.rb

# External share buttons visibility
Then("I should see the external share buttons section") do
  expect(page).to have_css('.share-buttons')
end

Then("I should not see the external share buttons section") do
  expect(page).not_to have_css('.share-buttons')
end

Then("I should see a {string} share button") do |platform|
  expect(page).to have_css(".share-btn", text: /#{platform}/i)
end

Then("I should see an {string} share button") do |platform|
  expect(page).to have_css(".share-btn", text: /#{platform}/i)
end

# WhatsApp
Then("the {string} share button should link to WhatsApp with event details") do |_platform|
  event = Event.find_by(name: "Test Event")
  whatsapp_link = find('.share-whatsapp')
  href = whatsapp_link[:href]
  
  expect(href).to include('wa.me')
  expect(href).to include(URI.encode_www_form_component(event.name))
end

# iMessage/SMS
Then("the {string} share button should have an SMS link with event details") do |_platform|
  event = Event.find_by(name: "Test Event")
  sms_link = find('.share-sms')
  href = sms_link[:href]
  
  expect(href).to start_with('sms:')
  expect(href).to include('body=')
  expect(href).to include(URI.encode_www_form_component(event.name))
end

# Telegram
Then("the {string} share button should link to Telegram with event details") do |_platform|
  event = Event.find_by(name: "Test Event")
  telegram_link = find('.share-telegram')
  href = telegram_link[:href]
  
  expect(href).to include('t.me/share')
  expect(href).to include(URI.encode_www_form_component(event.name))
end

# Twitter
Then("the {string} share button should link to Twitter with event details") do |_platform|
  event = Event.find_by(name: "Test Event")
  twitter_link = find('.share-twitter')
  href = twitter_link[:href]
  
  expect(href).to include('twitter.com/intent/tweet')
  expect(href).to include(URI.encode_www_form_component(event.name))
end

# Facebook
Then("the {string} share button should link to Facebook sharer") do |_platform|
  facebook_link = find('.share-facebook')
  href = facebook_link[:href]
  
  expect(href).to include('facebook.com/sharer')
end

# Email
Then("the {string} share button should have a mailto link with event details") do |_platform|
  event = Event.find_by(name: "Test Event")
  email_link = find('.share-email')
  href = email_link[:href]
  
  expect(href).to start_with('mailto:')
  expect(href).to include('subject=')
  expect(href).to include(URI.encode_www_form_component(event.name))
end

# Messenger
Then("the {string} share button should link to Facebook Messenger") do |_platform|
  messenger_link = find('.share-messenger')
  href = messenger_link[:href]
  
  expect(href).to include('facebook.com')
end

# Copy Link
Then("I should see a {string} button with the event URL") do |_button_text|
  event = Event.find_by(name: "Test Event")
  copy_button = find('.share-copy')
  
  expect(copy_button['data-url']).to include("/performances/#{event.id}/details")
end

# Instagram
Then("the Instagram button should have event data attributes") do
  event = Event.find_by(name: "Test Event")
  instagram_button = find('#instagram-share-btn')
  
  expect(instagram_button['data-event-name']).to eq(event.name)
  expect(instagram_button['data-event-venue']).to eq(event.venue)
  expect(instagram_button['data-share-url']).to include("/performances/#{event.id}/details")
end

# Visit event details page (alternate wording)
When("I visit the Event Details page for {string}") do |event_name|
  event = Event.find_by(name: event_name)
  visit details_performance_path(event)
end

# In-app sharing - Friends
Then("I should see the friend selector before external share buttons") do
  expect(page).to have_css('.share-inapp-section')
  expect(page).to have_css('.share-friend-select')
  
  # Verify order: in-app section comes before external buttons in HTML
  page_html = page.body
  inapp_pos = page_html.index('share-inapp-section')
  external_pos = page_html.index('share-buttons-grid')
  
  expect(inapp_pos).to be < external_pos
end

Then("I should see {string} in the friend dropdown") do |prompt_text|
  select_element = find('.share-friend-select')
  expect(select_element).to have_css('option', text: prompt_text)
end

Then("I should not see the friend selector") do
  expect(page).not_to have_css('.share-friend-select')
end

# In-app sharing - Groups
Given("I have a group called {string}") do |group_name|
  current_user = @logged_in_user || User.find_by(username: "alice123")
  group = Group.create!(name: group_name, creator: current_user)
  GroupMember.create!(group: group, user: current_user, role: 'admin')
end

Then("I should see {string} group share button") do |group_name|
  # Use have_button for input[type=submit] elements since their text is in the value attribute
  expect(page).to have_button(group_name, class: 'share-group-btn')
end

Then("the group button should appear before external share buttons") do
  expect(page).to have_css('.share-groups-row')
  expect(page).to have_css('.share-buttons')
  
  # Verify groups row is within in-app section which is before external
  page_html = page.body
  groups_pos = page_html.index('share-groups-row')
  external_pos = page_html.index('share-buttons-grid')
  
  expect(groups_pos).to be < external_pos
end

# Instagram modal (JavaScript dependent - check structure exists)
Then("the Instagram modal should be present in the page") do
  expect(page).to have_css('#instagram-modal', visible: false)
  expect(page).to have_css('.share-modal-content', visible: false)
end
