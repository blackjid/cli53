@commands
Feature: commands
  Scenario: I can create a wildcard record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain '* A 127.0.0.1'"
    Then the domain "$domain" has record "*.$domain. 3600 IN A 127.0.0.1"

  Scenario: I can create a resource record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a A 127.0.0.1'"
    Then the domain "$domain" has record "a.$domain. 3600 IN A 127.0.0.1"

  Scenario: I can create a resource record (full)
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a.$domain. A 127.0.0.1'"
    Then the domain "$domain" has record "a.$domain. 3600 IN A 127.0.0.1"

  Scenario: I can create a failover record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i "The First" --failover PRIMARY --health-check 6bb57c41-879a-42d0-acdd-ed6472f08eb9 $domain 'failover 300 IN A 127.0.0.1'"
    Then the domain "$domain" has record "failover.$domain. 300 IN A 127.0.0.1 ; AWS routing="FAILOVER" failover="PRIMARY" healthCheckId="6bb57c41-879a-42d0-acdd-ed6472f08eb9" identifier="The First""

  Scenario: I can create a geolocation record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i Africa --continent-code AF $domain 'geo 300 IN A 127.0.0.1'"
    Then the domain "$domain" has record "geo.$domain. 300 IN A 127.0.0.1 ; AWS routing="GEOLOCATION" continentCode="AF" identifier="Africa""

  Scenario: I can create a geolocation record with a country code and subdivision code
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i California --country-code US --subdivision-code CA $domain 'geo 300 IN A 127.0.0.1'"
    Then the domain "$domain" has record "geo.$domain. 300 IN A 127.0.0.1 ; AWS routing="GEOLOCATION" countryCode="US" subdivisionCode="CA" identifier="California""

  Scenario: I can create a latency record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i USWest1 --region us-west-1 $domain 'latency 300 IN A 127.0.0.1'"
    Then the domain "$domain" has record "latency.$domain. 300 IN A 127.0.0.1 ; AWS routing="LATENCY" region="us-west-1" identifier="USWest1""

  Scenario: I can create a weighted record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i One --weight 1 $domain 'weighted 300 IN A 127.0.0.1'"
    Then the domain "$domain" has record "weighted.$domain. 300 IN A 127.0.0.1 ; AWS routing="WEIGHTED" weight=1 identifier="One""

  Scenario: I can create a weighted record with zero weight
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i Zero --weight 0 $domain 'weighted 300 IN A 127.0.0.1'"
    Then the domain "$domain" has record "weighted.$domain. 300 IN A 127.0.0.1 ; AWS routing="WEIGHTED" weight=0 identifier="Zero""

  Scenario: I can create an alias
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'www A 127.0.0.1'"
    When I run "cli53 rrcreate $domain 'alias 86400 AWS ALIAS A www $self false'"
    Then the domain "$domain" has record "alias.$domain. 86400 AWS ALIAS A www $self false"

  Scenario: I can create a round robin A record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a A 127.0.0.1' 'a A 127.0.0.2'"
    Then the domain "$domain" has record "a.$domain. 3600 IN A 127.0.0.1"
    And the domain "$domain" has record "a.$domain. 3600 IN A 127.0.0.2"

  Scenario: I can create an MX record with multiple entries
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'mail MX 10 mailserver1.' 'mail MX 20 mailserver2.'"
    Then the domain "$domain" has record "mail.$domain. 3600 IN MX 10 mailserver1."
    And the domain "$domain" has record "mail.$domain. 3600 IN MX 20 mailserver2."

  Scenario: I can create a TXT record with multiple values
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'txt TXT "a" "b"'"
    Then the domain "$domain" has record "txt.$domain. 3600 IN TXT "a" "b""
    And the domain "$domain" has 3 records
    # NS+SOA+TXT

  Scenario: I can replace a resource record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a A 127.0.0.1'"
    And I run "cli53 rrcreate --replace $domain 'a A 127.0.0.2'"
    Then the domain "$domain" has record "a.$domain. 3600 IN A 127.0.0.2"

  Scenario: replace is case-insensitive
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'record A 127.0.0.1'"
    And I run "cli53 rrcreate --replace $domain 'Record A 127.0.0.2'"
    Then the domain "$domain" has record "record.$domain. 3600 IN A 127.0.0.2"

  Scenario: I can replace multiple records
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a A 127.0.0.1' 'mail MX 5 mailserver0.' 'mail MX 10 mailserver1.'"
    And I run "cli53 rrcreate --replace $domain 'a A 127.0.0.2' 'mail MX 20 mailserver2.'"
    Then the domain "$domain" has record "a.$domain. 3600 IN A 127.0.0.2"
    And the domain "$domain" has record "mail.$domain. 3600 IN MX 20 mailserver2."

  Scenario: I can replace a weighted record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i One --weight 1 $domain 'a A 127.0.0.1'"
    And I run "cli53 rrcreate -i Two --weight 2 $domain 'a A 127.0.0.2'"
    And I run "cli53 rrcreate --replace -i One --weight 3 $domain 'a A 127.1.0.1'"
    Then the domain "$domain" has record "a.$domain. 3600 IN A 127.1.0.1 ; AWS routing="WEIGHTED" weight=3 identifier="One""
    And the domain "$domain" has record "a.$domain. 3600 IN A 127.0.0.2 ; AWS routing="WEIGHTED" weight=2 identifier="Two""

  Scenario: I can replace a wildcard record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain '*.wildcard A 127.0.0.1'"
    And I run "cli53 rrcreate --replace $domain '*.wildcard A 127.0.0.2'"
    Then the domain "$domain" has record "*.wildcard.$domain. 3600 IN A 127.0.0.2"

  Scenario: I can delete a resource record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a A 127.0.0.1'"
    And I run "cli53 rrdelete $domain a A"
    Then the domain "$domain" doesn't have record "a.$domain. 3600 IN A 127.0.0.1"

  Scenario: I can delete a resource record by identifier
    Given I have a domain "$domain"
    When I run "cli53 rrcreate -i One --weight 1 $domain 'weighted.$domain. 300 IN A 127.0.0.1'"
    And I run "cli53 rrcreate -i Two --weight 2 $domain 'weighted.$domain. 300 IN A 127.0.0.2'"
    And I run "cli53 rrdelete -i One $domain weighted A"
    Then the domain "$domain" doesn't have record "weighted.$domain. 300 IN A 127.0.0.1 ; AWS routing="WEIGHTED" weight=1 identifier="One""
    And the domain "$domain" has record "weighted.$domain. 300 IN A 127.0.0.2 ; AWS routing="WEIGHTED" weight=2 identifier="Two""

  Scenario: I can delete a wildcard record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain '*.wildcard A 127.0.0.1'"
    And I run "cli53 rrdelete $domain *.wildcard A"
    Then the domain "$domain" doesn't have record "*.wildcard.$domain. 3600 IN A 127.0.0.1"

  Scenario: I can purge a domain with child NS record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a NS b.example.com.'"
    And I run "cli53 rrpurge --confirm $domain"
    Then the domain "$domain" doesn't have record "a.$domain. 3600 IN NS b.example.com."

  Scenario: I can delete a domain with a child NS record
    Given I have a domain "$domain"
    When I run "cli53 rrcreate $domain 'a NS b.example.com.'"
    And I run "cli53 delete --purge $domain"
    Then the domain "$domain" is deleted
