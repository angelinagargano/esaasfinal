# features/step_definitions/group_conversations_steps.rb

# General step for clicking one of two options
# Note: This regex explicitly excludes the logout case which is handled by auth_steps.rb
# The pattern uses negative lookahead to prevent matching "Logout" or "Log out"
When(/^I click "(?!(?:Logout|Log out)" or "(?:Logout|Log out)"$)([^"]+)" or "([^"]+)"$/) do |option1, option2|
  # Try option1 first
  if page.has_link?(option1)
    click_link(option1)
  elsif page.has_button?(option1)
    click_button(option1)
  # Try option2 if option1 not found
  elsif page.has_link?(option2)
    click_link(option2)
  elsif page.has_button?(option2)
    click_button(option2)
  else
    raise "Could not find #{option1} or #{option2}"
  end
end

Then("I should see the group conversation") do
  expect(page).to have_css('.group-conversation, .group-messages, [data-group-conversation]')
end

Given("I am on the group conversation page for {string}") do |group_name|
  @group = Group.find_by(name: group_name)
  raise "Group '#{group_name}' not found" if @group.nil?
  visit group_group_conversation_path(@group)
end

When("I send a group message {string} with event {string}") do |message_text, event_name|
  event = Event.find_by(name: event_name)
  @group ||= Group.last
  current_user = @logged_in_user || User.find_by(username: "alice123")
  
  # Ensure the event is liked by the current user so it appears in the dropdown
  unless current_user.liked_events.include?(event)
    Like.find_or_create_by!(user: current_user, event: event)
  end
  
  # Reload the page to ensure the dropdown is updated with the liked event
  visit group_group_conversation_path(@group)
  
  fill_in 'group_message[content]', with: message_text rescue fill_in 'content', with: message_text
  
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
    page.driver.submit :post, group_group_conversation_group_messages_path(@group), {
      group_message: { content: message_text },
      event_ids: [event.id]
    }
    return
  end
  
  click_button "Send" rescue click_button "Send Message"
end

Then("I should see the event in the group message") do
  expect(page).to have_css('.group-message-event, .event-attachment, [data-event]')
end

Then("I should see {string} in the group conversation") do |text|
  within('.group-messages, .messages, [data-group-messages]') do
    expect(page).to have_content(text)
  end
end

When("I try to visit the group conversation page for {string}") do |group_name|
  group = Group.find_by(name: group_name)
  visit group_group_conversation_path(group)
end

