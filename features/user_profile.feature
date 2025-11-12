Feature: User Profile
  Users can view their details, saved events, and edit their information

  Background:
    Given the user has logged in and created an account
    And the following events exist:
      | Name                                               | Venue               | Date             | Time   | Style         | Location | Borough  | Price | Description                     | Tickets                   |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater  | November 11, 2025 | 7:30 PM | Hip-hop | Chelsea  | Manhattan | $32  | Well-known for painting rich tapestries | https://shop.joyce.org/8129/8130 |
      | For All Your Life                                   | BAM Brooklyn Academy of Music | December 3, 2025 | 7:30 PM | Modern  | Brooklyn | Brooklyn | $35  | A contemporary dance showcase | https://bam.org/forallyourlife |

  Scenario: Viewing user information (username, name, email)
    Given I am on the User Profile page
    Then I should see my username, name, and email

  Scenario: Redirect to login if not logged in
    Given I am logged out
    When I visit the User Profile page for user "alice123"
    Then I should be redirected to the Login page
    And I should see "Please log in first"

  Scenario: Editing user information (username, name, email)
    Given I am on the User Profile page
    When I click "Edit my information" on the User Profile page
    Then I should be on the User Edit page
    When I change Username to "alice777"
    And I change Name to "Alice Updated"
    And I change Email to "alice.updated@example.com"
    And I click "Save changes" on the User Edit page
    Then I should be redirected to the User Profile page
    And I should see "alice777"
    And I should see "Alice Updated"
    And I should see "alice.updated@example.com"

  Scenario: Editing user information with invalid data shows errors
    Given I am logged in as "alice123"
    And I am on the User Edit page
    When I change Email to "" 
    And I click "Save changes"
    Then I should see an error message

  Scenario: Editing password
    Given I am on the User Profile page
    When I click "Edit my information" on the User Profile page
    Then I should be on the User Edit page
    When I change Password to "newpassword123"
    And I click "Save changes" on the User Edit page
    Then I should be redirected to the User Profile page
    And I should see "Your information was successfully updated"

  Scenario: Viewing liked events when user has no liked events
    Given I do not have any liked events
    And I am on the User Profile page
    Then I should see "You haven't liked any events yet"

  Scenario: Viewing liked events when user has liked events
    Given I have liked the event "Rennie Harris Puremovement American Street Dance Theater"
    And I am on the User Profile page
    Then I should see "Rennie Harris Puremovement American Street Dance Theater" in my liked events
    And I should see a list of my liked events in chronological order

  Scenario: Viewing more details about a liked event
    Given I have liked the event "Rennie Harris Puremovement American Street Dance Theater"
    And I am on the User Profile page
    When I click on an event card in the liked events list
    Then I should be redirected to the Event Details page for that event

  Scenario: Canceling edit without saving
    Given I am on the User Profile page
    When I click "Edit my information" on the User Profile page
    Then I should be on the User Edit page
    When I change Username to "temporary_username"
    And I click "Cancel" on the User Edit page
    Then I should be redirected to the User Profile page
    And I should not see "temporary_username"

  Scenario: Visiting user show redirects to profile
    Given I am logged in as "alice123"
    When I visit the show page for user "alice123"
    Then I should be redirected to my User Profile page


