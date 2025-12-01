# features/step_definitions/conversations_steps.rb

Given("I am on the Conversations page") do
  visit conversations_path
end

Then("I should see my conversations") do
  expect(page).to have_css('.conversations-list, .conversation, [data-conversation]')
end

# Removed duplicate step definition - using the one from friendships_steps.rb instead

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
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  # Ensure the event is liked by the current user so it appears in the dropdown
  unless current_user.liked_events.include?(event)
    Like.find_or_create_by!(user: current_user, event: event)
  end
  
  # Reload the page to ensure the dropdown is updated with the liked event
  visit conversation_path(@conversation)
  
  fill_in 'message[content]', with: message_text rescue fill_in 'content', with: message_text
  
  # If there's an event selector, select it
  if page.has_field?('event_ids[]')
    # The dropdown shows "Event Name - Date", so try to match by partial text or select by value
    event_text = "#{event.name} - #{event.date}"
    begin
      # Try selecting by value first (more reliable)
      find("select[name='event_ids[]'] option[value='#{event.id}']").select_option
    rescue
      # If exact match fails, try selecting by visible text
      select event_text, from: 'event_ids[]'
    end
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
  
  # Scope to the specific conversation using data attribute to avoid ambiguity
  within("[data-conversation='#{conversation.id}']") do
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

When("I try to send a message to the conversation between {string} and {string}") do |username1, username2|
  user1 = User.find_by(username: username1)
  user2 = User.find_by(username: username2)
  
  conversation = Conversation.find_by(
    user1: [user1, user2].min_by(&:id),
    user2: [user1, user2].max_by(&:id)
  )
  
  page.driver.submit :post, conversation_messages_path(conversation), {
    message: { content: "Unauthorized message" }
  }
end

When("I try to send an empty message") do
  @conversation ||= Conversation.last
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  page.driver.submit :post, conversation_messages_path(@conversation), {
    message: { content: "" }
  }
end

Then("I should see an error message about the message") do
  has_error_text = page.has_content?("Message must have content or at least one event")
  has_alert = page.has_css?('.alert')
  expect(has_error_text || has_alert).to be true
end

Then("I should be redirected to the Conversations page") do
  expect(current_path).to eq(conversations_path)
end

Given("{string} has sent a message {string} in the conversation") do |username, message_text|
  user = User.find_by(username: username)
  @conversation ||= Conversation.last
  Message.create!(conversation: @conversation, sender: user, content: message_text, read: false)
end

Then("the message should be marked as read") do
  @conversation ||= Conversation.last
  current_user = @logged_in_user || User.find_by(username: "alice123")
  unread_messages = @conversation.messages.where.not(sender: current_user).where(read: false)
  expect(unread_messages.count).to eq(0)
end

When("I check the recipient of the message from {string}") do |username|
  user = User.find_by(username: username)
  @conversation ||= Conversation.last
  @message = @conversation.messages.find_by(sender: user)
  @recipient = @message.recipient
end

Then("the recipient should be {string}") do |username|
  expected_recipient = User.find_by(username: username)
  expect(@recipient).to eq(expected_recipient)
end

When("I mark the message as read") do
  @message ||= Message.last
  @message.mark_as_read!
end

When("I try to view the conversation between {string} and {string}") do |username1, username2|
  user1 = User.find_by(username: username1)
  user2 = User.find_by(username: username2)
  
  conversation = Conversation.find_by(
    user1: [user1, user2].min_by(&:id),
    user2: [user1, user2].max_by(&:id)
  )
  
  visit conversation_path(conversation)
end

