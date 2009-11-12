Feature:
  In order to deploy my application
  As a systems administrator
  I want to know that the config files are legal

  Scenario: Valid Apache config
    Given a config file template apache2.conf in etc/apache2
    When I generate it
    Then there should be a file called apache2.conf in etc/apache2
    And it should be valid

