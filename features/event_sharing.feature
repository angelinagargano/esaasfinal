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
    And I fill in "Message" with "Check this out!"
    And I click "Share via Message"
    Then I should see "Event shared in message!"
    And I should be on the conversation page with "bob456"
    And I should see "Test Event" in the conversation

  Scenario: Cannot share event to non-friend
    Given an existing user with username "charlie789" and password "password123"
    And I am on the Event Details page for "Test Event"
    When I try to share the event to "charlie789"
    Then I should see "You can only share events with friends"

