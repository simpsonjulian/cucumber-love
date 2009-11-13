Feature:
  In order to deploy my application
  As a systems administrator
  I want to know that the config files are legal

  Scenario: Valid Apache config
    Given a config file template apache2.conf in /etc/apache2
    When I generate it
    Then there should be a file called apache2.conf in etc/apache2
    And it should be a valid apache file

  Scenario: Valid Sudo config
    Given a sudoers file in etc/sudoers
    Then it should be a valid sudoers file

  Scenario: Valid Postfix config
    Given a postfix dir in etc/postfix
    Then it should be a valid postfix dir
# postfix is less useful than I remember, but will still barf on a file that doesn't fit the format.
