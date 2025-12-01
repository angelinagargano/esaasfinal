Feature: Direct Messages
  Users can send and receive direct messages with friends.

  Background:
    Given I am logged in as "alice123"
    And an existing user with username "bob456" and password "password123"
    And "alice123" and "bob456" are friends

  Scenario: Viewing conversations list
    Given I am on the Conversations page
    Then I should see my conversations

  Scenario: Creating a new conversation
    Given I am on the User Profile page
    When I click "Message" for friend "bob456"
    Then I should be on the conversation page with "bob456"

  Scenario: Viewing a conversation
    Given a conversation exists between "alice123" and "bob456"
    When I visit the conversation with "bob456"
    Then I should see the conversation
    And I should see a message input field

  Scenario: Sending a message
    Given a conversation exists between "alice123" and "bob456"
    And I am on the conversation page with "bob456"
    When I fill in "Content" with "Hello Bob!"
    And I click "Send"
    Then I should see "Message sent!"
    And I should see "Hello Bob!" in the conversation

  Scenario: Sending a message with an event
    Given a conversation exists between "alice123" and "bob456"
    And the following events exist:
      | Name | Venue | Date | Time | Style | Location | Price | Description | Tickets |
      | Test Event | Test Venue | 2025-12-01 | 7:30 PM | Hip-hop | Manhattan | $30 | Test | https://test.com |
    And I am on the conversation page with "bob456"
    When I send a message "Check this out!" with event "Test Event"
    Then I should see "Message sent!"
    And I should see the event in the message

  Scenario: Deleting a conversation
    Given a conversation exists between "alice123" and "bob456"
    And I am on the Conversations page
    When I delete the conversation with "bob456"
    Then I should see "Conversation deleted"
    And I should not see the conversation with "bob456"

  Scenario: Cannot message non-friend
    Given an existing user with username "charlie789" and password "password123"
    When I try to create a conversation with "charlie789"
    Then I should see "You can only message your friends"

  Scenario: Cannot send message to conversation I'm not part of
    Given an existing user with username "charlie789" and password "password123"
    And a conversation exists between "bob456" and "charlie789"
    And I am logged in as "alice123"
    When I try to send a message to the conversation between "bob456" and "charlie789"
    Then I should see "You don't have access to this conversation"
    And I should be redirected to the Conversations page

  Scenario: Cannot view conversation I'm not part of
    Given an existing user with username "charlie789" and password "password123"
    And a conversation exists between "bob456" and "charlie789"
    And I am logged in as "alice123"
    When I try to view the conversation between "bob456" and "charlie789"
    Then I should see "You don't have access to this conversation"
    And I should be redirected to the Conversations page

  Scenario: Sending empty message without events fails
    Given a conversation exists between "alice123" and "bob456"
    And I am on the conversation page with "bob456"
    When I try to send an empty message
    Then I should see an error message about the message

  Scenario: Viewing conversation marks messages as read
    Given a conversation exists between "alice123" and "bob456"
    And "bob456" has sent a message "Hello Alice!" in the conversation
    And I am logged in as "alice123"
    When I visit the conversation with "bob456"
    Then the message should be marked as read

  Scenario: Marking a message as read directly
    Given a conversation exists between "alice123" and "bob456"
    And "bob456" has sent a message "Hello Alice!" in the conversation
    When I mark the message as read
    Then the message should be marked as read

  Scenario: Message recipient is correctly identified
    Given a conversation exists between "alice123" and "bob456"
    And "alice123" has sent a message "Hello Bob!" in the conversation
    When I check the recipient of the message from "alice123"
    Then the recipient should be "bob456"

