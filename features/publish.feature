Feature: Publish post
  In order to make a posts
  I will need to call my client on blog API

  Background:
  Given I have a blog control
  And all posts and comments cleaned out

  @wip
  Scenario: Publish post
    When I go to wordpress "home" page
    Then I should see "wordpress"
    When make following post:
    | title  | content                                                   | creation_date | image                               |
    | hey ho | this is my first post <br/> <img src="post_picture.jpg"/> |    01.08.2010 | spec/support/files/post_picture.jpg |
    And I go to wordpress "home" page
    Then I should see "hey ho"
    And I should see "this is my first post"
    And I should see "Posted on August 1, 2010 by admin"
