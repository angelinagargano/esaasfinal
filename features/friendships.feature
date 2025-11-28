Feature: Friendships
  Users can send friend requests, accept/reject requests, and manage friendships.

  Background:
    Given I am logged in as "alice123"
    And an existing user with username "bob456" and password "password123"
    And an existing user with username "charlie789" and password "password123"

  Scenario: Searching for friends
    Given I am on the Find Friends page
    When I search for username "bob"
    Then I should see "bob456" in the search results
    And I should see an "Add Friend" button for "bob456"

  Scenario: Sending a friend request successfully
    Given I am on the Find Friends page
    And I search for username "bob456"
    When I click "Add Friend" for user "bob456"
    Then I should see "Friend request sent"
    And "bob456" should have a pending friend request from "alice123"

  Scenario: Cannot send friend request to yourself
    Given I am on the Find Friends page
    And I search for username "alice"
    When I try to add myself as a friend
    Then I should see "Unable to send friend request"

  Scenario: Cannot send duplicate friend request
    Given I have sent a friend request to "bob456"
    When I try to send another friend request to "bob456"
    Then I should see "Unable to send friend request"

  Scenario: Accepting a friend request
    Given "bob456" has sent a friend request to "alice123"
    And I am on the User Profile page
    When I click "Accept" for friend request from "bob456"
    Then I should see "Friend request accepted"
    And "alice123" and "bob456" should be friends

  Scenario: Rejecting a friend request
    Given "bob456" has sent a friend request to "alice123"
    And I am on the User Profile page
    When I click "Reject" for friend request from "bob456"
    Then I should see "Friend request rejected"
    And "alice123" and "bob456" should not be friends

  Scenario: Unfriending a friend
    Given "alice123" and "bob456" are friends
    And I am on the User Profile page
    When I click "Unfriend" for friend "bob456"
    Then I should see "Unfriended successfully"
    And "alice123" and "bob456" should not be friends

  Scenario: Viewing pending friend requests
    Given "bob456" has sent a friend request to "alice123"
    And "charlie789" has sent a friend request to "alice123"
    And I am on the User Profile page
    Then I should see "Friend Requests Received" section
    And I should see "bob456" in pending requests
    And I should see "charlie789" in pending requests

  Scenario: Viewing friends list
    Given "alice123" and "bob456" are friends
    And "alice123" and "charlie789" are friends
    And I am on the User Profile page
    Then I should see "My Friends" section
    And I should see "bob456" in my friends list
    And I should see "charlie789" in my friends list

  Scenario: Viewing outgoing pending requests
    Given I have sent a friend request to "bob456"
    And I am on the User Profile page
    Then I should see "bob456" in outgoing pending requests
    And I should see "Friend request sent" button for "bob456"

  Scenario: Accepting non-existent friend request shows error
    Given I am on the User Profile page
    When I try to accept a non-existent friend request
    Then I should see "Unable to accept friend request"

  Scenario: Rejecting non-existent friend request shows error
    Given I am on the User Profile page
    When I try to reject a non-existent friend request
    Then I should see "Unable to reject friend request"

  Scenario: Unfriending when not friends shows error
    Given "alice123" and "bob456" are not friends
    And I am on the User Profile page
    When I try to unfriend "bob456"
    Then I should see "Unable to unfriend"

  Scenario: Friendship save fails shows error
    Given I am on the Find Friends page
    And I search for username "bob456"
    And I stub Friendship to fail on save
    When I click "Add Friend" for user "bob456"
    Then I should see "Unable to send friend request"

  Scenario: Friendship update fails shows error
    Given "bob456" has sent a friend request to "alice123"
    And I am on the User Profile page
    And I stub Friendship to fail on update
    When I click "Accept" for friend request from "bob456"
    Then I should see "Unable to accept friend request"

  Scenario: Searching for friends without being logged in
    Given I am logged out
    And I am on the Find Friends page
    When I search for username "bob"
    Then I should see "bob456" in the search results