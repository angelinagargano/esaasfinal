Feature: Sharing Events
  Users can share events with friends via messages.

  Background:
    Given I am logged in as "alice123"
    And an existing user with username "bob456" and password "password123"
    And "alice123" and "bob456" are friends
    And the following events exist:
      | Name | Venue | Date | Time | Style | Location | Price | Description | Tickets |
      | Test Event | Test Venue | 2025-12-01 | 7:30 PM | Hip-hop | Manhattan | $30 | Test | https://test.com |

  Scenario: Sharing an event to a friend
    Given I am on the Event Details page for "Test Event"
    When I select "bob456" as the friend
    And I click "Send"
    Then I should see "Event shared in message!"
    And I should be on the conversation page with "bob456"
    And I should see "Test Event" in the conversation

  Scenario: Cannot share event to non-friend
    Given an existing user with username "charlie789" and password "password123"
    And I am on the Event Details page for "Test Event"
    When I try to share the event to "charlie789"
    Then I should see "You can only share events with friends"

  Scenario: Cannot share event without selecting a friend
    Given I am on the Event Details page for "Test Event"
    When I try to share the event without selecting a friend
    Then I should see "Please select a friend to share with"

  Scenario: Sharing the same event again updates existing share instead of creating duplicate
    Given I am on the Event Details page for "Test Event"
    When I select "bob456" as the friend
    And I click "Send"
    Then I should see "Event shared in message!"
    And I should see 1 message with "Test Event" in the conversation
    When I go to the Event Details page for "Test Event"
    And I select "bob456" as the friend
    And I click "Send"
    Then I should see "Event share updated!"
    And I should see 1 message with "Test Event" in the conversation
    And the message should contain "Check out this event!"

  Scenario: Re-shared event moves to bottom of conversation
    Given a conversation exists between "alice123" and "bob456"
    And I am on the conversation page with "bob456"
    When I send a message "Hello!" without events
    Then I should see "Hello!" in the conversation
    When I go to the Event Details page for "Test Event"
    And I select "bob456" as the friend
    And I click "Send"
    Then I should see "Event shared in message!"
    When I go to the conversation page with "bob456"
    And I send a message "What do you think?" without events
    Then the event "Test Event" should appear before "What do you think?" in the conversation
    When I go to the Event Details page for "Test Event"
    And I select "bob456" as the friend
    And I click "Send"
    Then I should see "Event share updated!"
    And the event "Test Event" should appear after "What do you think?" in the conversation

  Scenario: Multiple shares of same event only shows one event card
    Given I am on the Event Details page for "Test Event"
    When I share "Test Event" to "bob456" 3 times
    Then I should see 1 message with "Test Event" in the conversation
    And I should see 1 event card for "Test Event"

