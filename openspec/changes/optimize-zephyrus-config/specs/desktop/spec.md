# Spec: Desktop Environment

## MODIFIED Requirements

### Compositor
The system must use Niri as the primary Wayland compositor.

#### Scenario: Session Login
Given the display manager starts
When the user logs in
Then the Niri session should be launched

### Desktop Shell
The system must use DankMaterialShell for the desktop interface.

#### Scenario: Desktop Interface
Given the Niri session is running
Then DankMaterialShell widgets and services should be active
