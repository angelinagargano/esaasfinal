Feature: External Sharing
  Users can share events to external platforms like WhatsApp, iMessage, Instagram, etc.

  Background:
    Given I am logged in as "alice123"
    And the following events exist:
      | Name       | Venue       | Date       | Time    | Style   | Location  | Borough   | Price | Description      | Tickets            |
      | Test Event | Test Venue  | 2025-12-01 | 7:30 PM | Hip-hop | Manhattan | Manhattan | $30   | A great event!   | https://test.com   |

  Scenario: External share buttons are visible on event details page
    When I go to the Event Details page for "Test Event"
    Then I should see the external share buttons section
    And I should see a "WhatsApp" share button
    And I should see an "iMessage" share button
    And I should see a "Telegram" share button
    And I should see a "Messenger" share button
    And I should see an "Instagram" share button
    And I should see a "Twitter" share button
    And I should see a "Facebook" share button
    And I should see an "Email" share button
    And I should see a "Copy Link" share button

  Scenario: WhatsApp share button has correct URL
    When I go to the Event Details page for "Test Event"
    Then the "WhatsApp" share button should link to WhatsApp with event details

  Scenario: iMessage/SMS share button has correct URL
    When I go to the Event Details page for "Test Event"
    Then the "iMessage" share button should have an SMS link with event details

  Scenario: Telegram share button has correct URL
    When I go to the Event Details page for "Test Event"
    Then the "Telegram" share button should link to Telegram with event details

  Scenario: Twitter share button has correct URL
    When I go to the Event Details page for "Test Event"
    Then the "Twitter" share button should link to Twitter with event details

  Scenario: Facebook share button has correct URL
    When I go to the Event Details page for "Test Event"
    Then the "Facebook" share button should link to Facebook sharer

  Scenario: Email share button has correct mailto link
    When I go to the Event Details page for "Test Event"
    Then the "Email" share button should have a mailto link with event details

  Scenario: Copy Link button is present
    When I go to the Event Details page for "Test Event"
    Then I should see a "Copy Link" button with the event URL

  Scenario: Instagram share button has correct data attributes
    When I go to the Event Details page for "Test Event"
    Then I should see an "Instagram" share button
    And the Instagram button should have event data attributes

  Scenario: Share buttons only visible when logged in
    Given I am logged out
    When I visit the Event Details page for "Test Event"
    Then I should not see the external share buttons section

  Scenario: In-app friend sharing appears above external buttons
    Given an existing user with username "bob456" and password "password123"
    And "alice123" and "bob456" are friends
    When I go to the Event Details page for "Test Event"
    Then I should see the friend selector before external share buttons
    And I should see "Send to a friend..." in the friend dropdown

  Scenario: In-app group sharing appears when user has groups
    Given I have a group called "Dance Friends"
    When I go to the Event Details page for "Test Event"
    Then I should see "Dance Friends" group share button
    And the group button should appear before external share buttons

  Scenario: No friend/group section when user has no friends or groups
    When I go to the Event Details page for "Test Event"
    Then I should not see the friend selector
    And I should see the external share buttons section

  Scenario: Messenger share button has correct URL
    When I go to the Event Details page for "Test Event"
    Then the "Messenger" share button should link to Facebook Messenger
