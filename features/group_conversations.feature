Feature: Group Messages
  Users can send messages in group conversations.

  Background:
    Given I am logged in as "alice123"
    And an existing user with username "bob456" and password "password123"
    And "alice123" and "bob456" are friends
    And a group "Dance Enthusiasts" exists created by "alice123"
    And "bob456" is a member of "Dance Enthusiasts"

  Scenario: Viewing group conversation
    Given I am on the group page for "Dance Enthusiasts"
    When I click "View Messages" or "Messages"
    Then I should see the group conversation
    And I should see a message input field

  Scenario: Sending a group message
    Given I am on the group conversation page for "Dance Enthusiasts"
    When I fill in "Content" with "Hello everyone!"
    And I click "Send"
    Then I should see "Message sent!"
    And I should see "Hello everyone!" in the group conversation

  Scenario: Sending a group message with an event
    Given the following events exist:
      | Name | Venue | Date | Time | Style | Location | Price | Description | Tickets |
      | Test Event | Test Venue | 2025-12-01 | 7:30 PM | Hip-hop | Manhattan | $30 | Test | https://test.com |
    And I am on the group conversation page for "Dance Enthusiasts"
    When I send a group message "Check this out!" with event "Test Event"
    Then I should see "Message sent!"
    And I should see the event in the group message

  Scenario: Non-member cannot view group conversation
    Given an existing user with username "charlie789" and password "password123"
    And I am logged in as "charlie789"
    When I try to visit the group conversation page for "Dance Enthusiasts"
    Then I should see "You must be a member of this group to view messages"

  Scenario: Non-member cannot send group message
    Given an existing user with username "charlie789" and password "password123"
    And I am logged in as "charlie789"
    When I try to send a message to the group conversation for "Dance Enthusiasts"
    Then I should see "You must be a member of this group to send messages"
    And I should be redirected to the Groups page

  Scenario: Sending empty group message without events fails
    Given I am on the group conversation page for "Dance Enthusiasts"
    When I try to send an empty group message
    Then I should see an error message about the group message

  Scenario: Group message recipients include all members and creator
    Given "alice123" has sent a group message "Hello everyone!" in "Dance Enthusiasts"
    When I check the recipients of the group message from "alice123"
    Then the recipients should include "alice123"
    And the recipients should include "bob456"

