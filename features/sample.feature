Feature: Test Wordpress
  In order to move forward
  I will need to deal with this mess

  Scenario: Load wordpress home page
    When I go to wordpress "home" page
    Then I should see "wordpress"
    When make following post:
    | title  | content               |
    | hey ho | this is my first post |
    And I go to wordpress "home" page
    Then I should see "hey ho"
    And I should see "this is my first post"
