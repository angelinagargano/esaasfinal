Feature: Preferences for Location and Borough
  As a user
  I want to filter events by specific locations and boroughs
  So that I can find events in my preferred areas

  Background:
    Given the following events exist:
      | Name                    | Venue              | Date       | Time   | Style    | Location          | Borough   | Price | Description | Tickets                |
      | Hip-hop Event           | The Joyce Theater  | 2025-11-11 | 7:30PM | Hip-hop  | Chelsea           | Manhattan | $32   | Great show   | https://example.com/1  |
      | Ballet Performance      | BAM                | 2025-11-12 | 8:00PM | Ballet   | Fort Greene       | Brooklyn  | $35   | Beautiful    | https://example.com/2  |
      | Contemporary Dance      | Mark Morris        | 2025-11-13 | 7:30PM | Contemporary | Fort Greene | Brooklyn  | $47   | Modern dance | https://example.com/3  |
      | Swing Night             | The Joyce Theater  | 2025-11-14 | 7:30PM | Swing    | Chelsea           | Manhattan | $32   | Fun evening  | https://example.com/4  |
      | Queens Event            | Queens Theater     | 2025-11-15 | 8:00PM | Hip-hop  | Long Island City  | Queens    | $25   | Queens show  | https://example.com/5  |
      | Greenwich Event         | Greenwich Venue    | 2025-11-16 | 8:00PM | Contemporary | Greenwich Village | Manhattan | $30   | Village show | https://example.com/6  |
      | Lincoln Square Event    | Lincoln Venue      | 2025-11-17 | 8:00PM | Ballet   | Lincoln Square    | Manhattan | $40   | Square show  | https://example.com/7  |
      | Times Square Event      | Times Venue        | 2025-11-18 | 8:00PM | Hip-hop  | Times Square      | Manhattan | $35   | Times show   | https://example.com/8  |
    And I am logged in as "TestUser"

  Scenario: Filter events by borough
    Given I am on the Preferences page
    When I select "Manhattan" for "Borough"
    And I select "Hip-hop" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see "Hip-hop Event"
    And I should not see "Swing Night"
    And I should not see "Ballet Performance"
    And I should not see "Queens Event"

  Scenario: Filter events by specific location
    Given I am on the Preferences page
    When I select "Chelsea" for "Location"
    And I select "Hip-hop" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see "Hip-hop Event"
    And I should not see "Swing Night"
    And I should not see "Ballet Performance"
    And I should not see "Queens Event"

  Scenario: Filter events by multiple locations
    Given I am on the Preferences page
    When I select "Chelsea" for "Location"
    And I select "Fort Greene" for "Location"
    And I select "No Preference" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see "Hip-hop Event"
    And I should see "Ballet Performance"
    And I should see "Contemporary Dance"
    And I should see "Swing Night"
    And I should not see "Queens Event"

  Scenario: Filter events by borough and location together
    Given I am on the Preferences page
    When I select "Brooklyn" for "Borough"
    And I select "Fort Greene" for "Location"
    And I select "Ballet" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see "Ballet Performance"
    And I should not see "Hip-hop Event"
    And I should not see "Contemporary Dance"
    And I should not see "Swing Night"

  Scenario: Select "No Preference" for location shows all locations
    Given I am on the Preferences page
    When I select "No Preference" for "Location"
    And I select "Hip-hop" for "Performance Type"
    And I press "Save Preferences"
    Then I should be redirected to the Home page
    And I should see "Hip-hop Event"
    And I should see "Queens Event"
    And I should not see "Ballet Performance"

  Scenario: View location options on preferences page
    Given I am on the Preferences page
    Then I should see the following options for Location:
      | Chelsea           |
      | Fort Greene       |
      | Greenwich Village |
      | Lincoln Square    |
      | Long Island City  |
      | Times Square      |
      | No Preference    |

  Scenario: View borough options on preferences page
    Given I am on the Preferences page
    Then I should see the following options for Borough:
      | Manhattan     |
      | Brooklyn      |
      | Queens        |
      | Staten Island |
      | No Preference |

