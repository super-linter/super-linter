Feature: Test for the no-dupe-scenario-names rule

Scenario: This is a Scenario for no-dupe-scenario-names
  Given I have 2 scenarios with the same name
  Then I should see a no-dupe-scenario-names error
