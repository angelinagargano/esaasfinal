Feature: Authentication
  Users can sign up and login to the site.

  Background:
    Given I have opened the app

  Scenario: Signing up successfully (flow: root -> signup -> login)
    Given I am on the Login page
    When I click "Sign up" on the Login page
    And I fill in the sign up form with:
      | Email             | alice@example.com        |
      | Name              | Alice Example            |
      | Username          | alice123                 |
      | Password          | password123 |
      | Confirm Password  | password123 |
    And I click "Sign up" on the Signup page
    Then I should be redirected to the Login page

  Scenario: Signing up with missing fields shows errors
    Given I am on the Sign up page
    When I fill in the sign up form with:
      | Email   |                        |
      | Name    | Alice                 |
      | Username| alice123              |
      | Password|                        |
      | Confirm Password  |               |
    And I click "Sign up" on the Signup page
    Then I should see an error message

  Scenario: Logging in successfully
    Given an existing user with username "alice123" and password "password123"
    Given I am on the Login page
    When I fill in the login form with:
      | Username | alice123      |
      | Password | password123   |
    And I click "Log in" on the Login page
    Then I should be redirected to the Home page

  Scenario: Invalid login shows an error
    Given I am on the Login page
    When I fill in the login form with:
      | Username | unknown       |
      | Password | wrong         |
    And I click "Log in" on the Login page
    Then I should see an error message

  Scenario: Logging out successfully
    Given an existing user with username "alice123" and password "password123"
    And I am on the Login page
    When I fill in the login form with:
      | Username | alice123      |
      | Password | password123   |
    And I click "Log in" on the Login page
    Then I should be redirected to the Home page
    When I click "Logout" or "Log out"
    Then I should be redirected to the root page
    And I should see "Logged out"
