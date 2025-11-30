Feature: Groups
  Users can create, manage, and interact with groups.

  Background:
    Given I am logged in as "alice123"
    And an existing user with username "bob456" and password "password123"
    And "alice123" and "bob456" are friends

  Scenario: Viewing groups index
    Given I am on the Groups page
    Then I should see my groups

  Scenario: Creating a new group
    Given I am on the Groups page
    When I click "Create New Group"
    And I fill in "Name" with "Dance Enthusiasts"
    And I fill in "Description" with "A group for dance lovers"
    And I click "Create Group"
    Then I should see "Group created successfully"
    And I should be on the group page for "Dance Enthusiasts"

  Scenario: Viewing a group
    Given a group "Dance Enthusiasts" exists created by "alice123"
    When I visit the group page for "Dance Enthusiasts"
    Then I should see "Dance Enthusiasts"
    And I should see the group description

  Scenario: Editing a group as admin
    Given a group "Dance Enthusiasts" exists created by "alice123"
    And I am on the group page for "Dance Enthusiasts"
    When I click "Edit Group"
    And I change "Description" to "Updated description"
    And I click "Update Group"
    Then I should see "Group updated successfully"
    And I should see "Updated description"

  Scenario: Deleting a group as admin
    Given a group "Dance Enthusiasts" exists created by "alice123"
    And I am on the group page for "Dance Enthusiasts"
    When I click "Delete Group"
    Then I should see "Group deleted successfully"
    And I should be on the Groups page

  Scenario: Adding a member to a group
    Given a group "Dance Enthusiasts" exists created by "alice123"
    And I am on the group page for "Dance Enthusiasts"
    When I add "bob456" to the group
    Then I should see "bob456 added to group"
    And "bob456" should be a member of "Dance Enthusiasts"

  Scenario: Removing a member from a group
    Given a group "Dance Enthusiasts" exists created by "alice123"
    And "bob456" is a member of "Dance Enthusiasts"
    And I am on the group page for "Dance Enthusiasts"
    When I remove "bob456" from the group
    Then I should see "Member removed from group"
    And "bob456" should not be a member of "Dance Enthusiasts"

  Scenario: Non-admin cannot edit group
    Given a group "Dance Enthusiasts" exists created by "alice123"
    And I am logged in as "bob456"
    And "bob456" is a member of "Dance Enthusiasts"
    When I visit the group page for "Dance Enthusiasts"
    Then I should not see "Edit Group"

  Scenario: Cannot add non-friend to group
    Given an existing user with username "charlie789" and password "password123"
    And a group "Dance Enthusiasts" exists created by "alice123"
    And I am on the group page for "Dance Enthusiasts"
    When I try to add "charlie789" to the group
    Then I should see "You can only add friends to groups"

