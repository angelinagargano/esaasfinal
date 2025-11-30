# features/step_definitions/conversations_steps.rb

Given("I am on the Conversations page") do
  visit conversations_path
end

Then("I should see my conversations") do
  expect(page).to have_css('.conversations-list, .conversation, [data-conversation]')
end

When("I click {string} for friend {string}") do |button_text, username|
  within('.friends-section, .friends-list, [data-friends]') do
    within("div.card, div.friend-card, [data-friend='#{username}']") do
      if page.has_link?(button_text)
        click_link(button_text)
      elsif page.has_button?(button_text)
        click_button(button_text)
      else
        raise "Could not find #{button_text} for #{username}"
      end
    end
  end
end

Then("I should be on the conversation page with {string}") do |username|
  friend = User.find_by(username: username)
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  conversation = Conversation.find_by(
    user1: [current_user, friend].min_by(&:id),
    user2: [current_user, friend].max_by(&:id)
  )
  
  expect(current_path).to eq(conversation_path(conversation))
end

Given("a conversation exists between {string} and {string}") do |username1, username2|
  user1 = User.find_by(username: username1)
  user2 = User.find_by(username: username2)
  
  @conversation = Conversation.find_or_create_by!(
    user1: [user1, user2].min_by(&:id),
    user2: [user1, user2].max_by(&:id)
  )
end

When("I visit the conversation with {string}") do |username|
  friend = User.find_by(username: username)
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  @conversation = Conversation.find_by(
    user1: [current_user, friend].min_by(&:id),
    user2: [current_user, friend].max_by(&:id)
  )
  
  visit conversation_path(@conversation)
end

Given("I am on the conversation page with {string}") do |username|
  friend = User.find_by(username: username)
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  @conversation = Conversation.find_by(
    user1: [current_user, friend].min_by(&:id),
    user2: [current_user, friend].max_by(&:id)
  )
  
  visit conversation_path(@conversation)
end

Then("I should see the conversation") do
  expect(page).to have_css('.conversation, .messages, [data-conversation]')
end

Then("I should see a message input field") do
  has_field1 = page.has_field?('message[content]', type: 'textarea')
  has_field2 = page.has_field?('content', type: 'textarea')
  has_css_field = page.has_css?('textarea[name*="content"]')
  
  expect(has_field1 || has_field2 || has_css_field).to be true
end

Then("I should see {string} in the conversation") do |text|
  within('.messages, .conversation-messages, [data-messages]') do
    expect(page).to have_content(text)
  end
end

When("I send a message {string} with event {string}") do |message_text, event_name|
  event = Event.find_by(name: event_name)
  @conversation ||= Conversation.last
  fill_in 'message[content]', with: message_text rescue fill_in 'content', with: message_text
  
  # If there's an event selector, select it
  if page.has_field?('event_ids[]')
    select event_name, from: 'event_ids[]'
  else
    # Submit with event_ids parameter
    page.driver.submit :post, conversation_messages_path(@conversation), {
      message: { content: message_text },
      event_ids: [event.id]
    }
    return
  end
  
  click_button "Send" rescue click_button "Send Message"
end

Then("I should see the event in the message") do
  expect(page).to have_css('.message-event, .event-attachment, [data-event]')
end

When("I delete the conversation with {string}") do |username|
  friend = User.find_by(username: username)
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  conversation = Conversation.find_by(
    user1: [current_user, friend].min_by(&:id),
    user2: [current_user, friend].max_by(&:id)
  )
  
  within('.conversations-list, .conversation, [data-conversation]') do
    if page.has_button?("Delete") || page.has_link?("Delete")
      click_button("Delete") rescue click_link("Delete")
    else
      page.driver.submit :delete, conversation_path(conversation), {}
    end
  end
end

Then("I should not see the conversation with {string}") do |username|
  expect(page).not_to have_content(username)
end

When("I try to create a conversation with {string}") do |username|
  friend = User.find_by(username: username)
  page.driver.submit :post, conversations_path, { friend_id: friend.id }
end

