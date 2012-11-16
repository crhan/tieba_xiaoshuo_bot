# -*- encoding : utf-8 -*-
Feature: User subscribe fiction
  User use sub command to subscribe a fiction.
  And the Bot should give feed back to user.

  Scenario: Subscribe to a new Fiction
    Given a fiction name with "神印王座" and user account "crhan123@gmail.com"
    When "crhan123@gmail.com" subscribe the never ever new Fiction "神印王座"
    And "crhan123@gmail.com" get a feedback which is "神印王座\n第二百九十五章 魔神皇之怒（中）, http://wapp.baidu.com/m?kz=1961070548"



  Scenario: Subscribe to a old Fiction

  Scenario: Subscribe to a subscribed Fiction
