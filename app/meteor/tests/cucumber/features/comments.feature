Feature: Comments

  As an employee
  I want to comment on documents
  So that colleagues can see what is happening

  Background:
    Given I am a 'call center employee' with the role 'inboundCalls'
    And I am logged in

  Scenario: Add comment
    Given an 'inbound call' with the following attributes:
      | Last name | First name | Telephone | Note | Private Patient |
      | Weisser   | Alex       | 123 456   | Test | false           |
    And I click on 'Inbound calls > Open inbound calls'
    And I fill in 'Add comment...' with 'This is a comment'
    And I press 'Enter'
    Then I should see the current time
    And I should see 'callcenteremployee' in '.username'
    And I should see 'C' in '.avatar'
    And I should see 'This is a comment'

  Scenario: Add comment in modal
    Given an 'inbound call' with the following attributes:
      | Last name | First name | Telephone | Note | Private Patient |
      | Weisser   | Alex       | 123 456   | Test | false           |
    And I click on 'Inbound calls > Open inbound calls'
    And I click on the link 'Mark as resolved'
    Then I should not see 'Alex'
    And I click on 'Inbound calls > Resolved inbound calls'
    And I click on '0'
    Then I should see the element '.modal'
    And I fill in 'Add comment...' with 'Commented from modal'
    And I press 'Enter'
    And I should see 'Commented from modal'
    When I fill in 'Add comment...' with 'Another comment from modal'
    And I click on the button titled 'Send'
    And inside the modal I click on 'Mark as unresolved'
    And I click on the button 'Close'
    And I click on 'Inbound calls > Open inbound calls'
    Then I should see 'Commented from modal'
    And I should see 'Another comment from modal'
