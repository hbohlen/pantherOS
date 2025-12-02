# Spec: Shell Environment

## MODIFIED Requirements

### Default Shell
The user's default shell must be Fish.

#### Scenario: User Login
Given the user `hbohlen` logs in
When a terminal is opened
Then the shell should be `fish`

### Default Terminal
The default terminal emulator must be Ghostty.

#### Scenario: Terminal Launch
Given the user launches the default terminal
Then `ghostty` should start
