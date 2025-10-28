Feature: View event details page
  Users should be able to view more detailed information about events and navigate to the ticket purchase page.

  Background:
    Given the following events exist:
      | Name                                                | Venue             | Date             | Time    | Style   | Location | Price | Description                                                                                                                              | Tickets                                    |
      | Rennie Harris Puremovement American Street Dance Theater | The Joyce Theater | November 11, 2025 | 7:30 PM | Hip-hop | Chelsea  | $32  | Well-known for painting rich tapestries of political, philosophical, and spiritual ideas, Rennie Harris returns with American Street Dance Theater, blending hip-hop and storytelling. | https://shop.joyce.org/8129/8130 |
      | For All Your Life                                   | BAM Brooklyn Academy of Music | December 3, 2025 | 7:30 PM | Modern  | Brooklyn | $35  | A contemporary dance showcase blending live music and emotional storytelling. | https://bam.org/forallyourlife |
      | A Very SW!NG OUT Holiday                            | Joyce Theater      | December 17, 2025 | 8:00 PM | Tap     | Manhattan | $40  | A tap dance celebration of the holiday season featuring live jazz music. | https://shop.joyce.org/holidaytap |

    And I am on the Home page
    Then at least 3 events should exist

  Scenario: Viewing more details about an event
    Given "Rennie Harris Puremovement American Street Dance Theater" exists
    When I click on its event card
    Then I should be on its Event Details page
    And I should see:
      | Venue       | The Joyce Theater |
      | Date        | November 11, 2025 |
      | Time        | 7:30 PM |
      | Style       | Hip-hop |
      | Location    | Chelsea |
      | Price       | $32 |
      | Description | Well-known for painting rich tapestries of political, philosophical, and spiritual ideas, Rennie Harris returns with American Street Dance Theater, blending hip-hop and storytelling. |
    And I should see a "Get Tickets" link leading to "https://shop.joyce.org/8129/8130"

  Scenario: Navigating to the ticket purchase page
    Given I am on the Event Details page for "Rennie Harris Puremovement American Street Dance Theater"
    When I click "Get Tickets"
    Then I should see a message: "You have viewed tickets for Rennie Harris Puremovement American Street Dance Theater"
    And I should be redirected to the ticket site
    And the URL should contain "https://shop.joyce.org/8129/8130"
