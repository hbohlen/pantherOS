# Spec: Power Management

## ADDED Requirements

### Intelligent Power Profiles
The system must automatically switch power profiles based on power source and battery level.

#### Scenario: AC Power
Given the laptop is plugged into AC power
When the power source is detected
Then the system should switch to "performance" mode

#### Scenario: Battery Power (High)
Given the laptop is on battery power
And the battery level is above 40%
Then the system should switch to "balanced" mode

#### Scenario: Battery Power (Low)
Given the laptop is on battery power
And the battery level is below 40%
Then the system should switch to "power-saver" mode

### Battery Health Preservation
The system must limit battery charging to prolong lifespan.

#### Scenario: Charge Limit
Given the system is configured for longevity
When the battery reaches 80% charge
Then charging should stop automatically
