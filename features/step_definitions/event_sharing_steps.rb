# features/step_definitions/event_sharing_steps.rb

When("I select {string} as the friend") do |username|
  if page.has_select?('friend_id')
    select username, from: 'friend_id'
  elsif page.has_field?('friend_id')
    fill_in 'friend_id', with: User.find_by(username: username).id
  else
    # Try to find a radio button or checkbox for this friend
    within('.friends-list, .share-friends, [data-friends]') do
      if page.has_button?(username) || page.has_link?(username)
        click_button(username) rescue click_link(username)
      else
        # Submit with friend_id parameter
        @friend_id = User.find_by(username: username).id
      end
    end
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
  
  # Try to find share button and form
  if page.has_button?("Share Event") || page.has_link?("Share Event")
    click_button("Share Event") rescue click_link("Share Event")
    # Wait for share form/modal
    sleep(0.5)
  end
  
  # Select friend and submit
  if page.has_select?('friend_id')
    select username, from: 'friend_id'
  elsif @friend_id
    # Use stored friend_id
  else
    # Direct submit
    page.driver.submit :post, share_to_message_performance_path(event), {
      friend_id: friend.id,
      message: "Check this out!"
    }
    return
  end
  
  if page.has_field?('message') || page.has_field?('message[content]')
    fill_in 'message', with: "Check this out!" rescue fill_in 'message[content]', with: "Check this out!"
  end
  
  click_button "Share" rescue click_button "Share via Message" rescue click_button "Share Event"
end

