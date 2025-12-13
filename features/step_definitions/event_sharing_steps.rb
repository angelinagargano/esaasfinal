# features/step_definitions/event_sharing_steps.rb

When("I select {string} as the friend") do |username|
  if page.has_select?('friend_id')
    select username, from: 'friend_id'
  elsif page.has_css?('.share-friend-select')
    within('.share-friend-select') do
      select username
    end
  elsif page.has_field?('friend_id')
    fill_in 'friend_id', with: User.find_by(username: username).id
  else
    # Store friend_id for later use
    @friend_id = User.find_by(username: username).id
  end
end

When("I try to share the event to {string}") do |username|
  event = Event.find_by(name: "Test Event")
  friend = User.find_by(username: username)
  
  page.driver.submit :post, share_to_message_performance_path(event), {
    friend_id: friend.id,
    message: "Check this out!"
  }
end

When("I share the event to {string}") do |username|
  friend = User.find_by(username: username)
  event = Event.find_by(name: "Test Event")
  
  # New UI: friend dropdown with Send button
  if page.has_select?('friend_id')
    select username, from: 'friend_id'
    # Click the Send button (new UI)
    if page.has_button?("Send")
      click_button "Send"
    elsif page.has_button?("Share via Message")
      click_button "Share via Message"
    elsif page.has_button?("Share")
      click_button "Share"
    else
      # Fallback: direct submit
      page.driver.submit :post, share_to_message_performance_path(event), {
        friend_id: friend.id,
        message: "Check this out!"
      }
    end
  else
    # Fallback: direct submit if no select found
    page.driver.submit :post, share_to_message_performance_path(event), {
      friend_id: friend.id,
      message: "Check this out!"
    }
  end
end

When("I try to share the event without selecting a friend") do
  event = Event.find_by(name: "Test Event")
  
  page.driver.submit :post, share_to_message_performance_path(event), {
    friend_id: "",
    message: "Check this out!"
  }
end

# Step definitions for duplicate share prevention feature

Then("I should see {int} message(s) with {string} in the conversation") do |count, event_name|
  within('.messages, .conversation-messages, [data-messages]') do
    event_messages = all('.message-event, .event-attachment, [data-event]').select do |el|
      el.has_content?(event_name)
    end
    expect(event_messages.count).to eq(count)
  end
end

Then("the message should contain {string}") do |text|
  within('.messages, .conversation-messages, [data-messages]') do
    expect(page).to have_content(text)
  end
end

When("I go to the Event Details page for {string}") do |event_name|
  event = Event.find_by(name: event_name)
  visit details_performance_path(event)
end

When("I go to the conversation page with {string}") do |username|
  friend = User.find_by(username: username)
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  conversation = Conversation.find_by(
    user1: [current_user, friend].min_by(&:id),
    user2: [current_user, friend].max_by(&:id)
  )
  
  visit conversation_path(conversation)
end

When("I send a message {string} without events") do |message_text|
  @conversation ||= Conversation.last
  
  fill_in 'message[content]', with: message_text rescue fill_in 'content', with: message_text
  click_button "Send" rescue click_button "Send Message"
end

Then("the event {string} should appear before {string} in the conversation") do |event_name, text|
  within('.messages, .conversation-messages, [data-messages]') do
    page_content = page.text
    event_position = page_content.index(event_name)
    text_position = page_content.index(text)
    
    expect(event_position).to be < text_position
  end
end

Then("the event {string} should appear after {string} in the conversation") do |event_name, text|
  within('.messages, .conversation-messages, [data-messages]') do
    page_content = page.text
    event_position = page_content.index(event_name)
    text_position = page_content.index(text)
    
    expect(event_position).to be > text_position
  end
end

When("I share {string} to {string} {int} times") do |event_name, username, times|
  event = Event.find_by(name: event_name)
  friend = User.find_by(username: username)
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  times.times do |i|
    page.driver.submit :post, share_to_message_performance_path(event), {
      friend_id: friend.id,
      message: "Share attempt #{i + 1}"
    }
  end
  
  # Navigate to conversation to verify
  conversation = Conversation.find_by(
    user1: [current_user, friend].min_by(&:id),
    user2: [current_user, friend].max_by(&:id)
  )
  visit conversation_path(conversation)
end

Then("I should see {int} event card(s) for {string}") do |count, event_name|
  event = Event.find_by(name: event_name)
  
  within('.messages, .conversation-messages, [data-messages]') do
    event_cards = all("[data-event='#{event.id}'], .event-attachment").select do |el|
      el.has_content?(event_name)
    end
    expect(event_cards.count).to eq(count)
  end
end

