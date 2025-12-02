#!/usr/bin/env fish

# Script to check and fix Nix permissions for using nix develop
# Can be used to diagnose issues and bootstrap permissions on other systems

# Colors for output
set -g RED '\033[0;31m'
set -g GREEN '\033[0;32m'
set -g YELLOW '\033[1;33m'
set -g NC '\033[0m' # No Color

echo "Checking Nix permissions for nix develop..."

# Function to print with color
function print_status
    printf "%b[INFO]%b %s\n" "$GREEN" "$NC" $argv
end

function print_warning
    printf "%b[WARNING]%b %s\n" "$YELLOW" "$NC" $argv
end

function print_error
    printf "%b[ERROR]%b %s\n" "$RED" "$NC" $argv
end

# Get current user
set CURRENT_USER (whoami)
set CURRENT_GROUP (id -gn)

# Check if running as root (to make changes) or just to check
if test (id -u) -eq 0
    print_status "Running as root - can make permission changes"
    set CAN_MAKE_CHANGES true
else
    print_warning "Not running as root - will only check permissions, not fix them"
    set CAN_MAKE_CHANGES false
end

# Function to check and fix Nix permissions
function check_and_fix_permissions
    set nix_path $argv[1]
    set expected_owner $argv[2]
    set expected_group $argv[3]

    if test -d "$nix_path"
        set actual_owner (stat -c "%U" "$nix_path")
        set actual_group (stat -c "%G" "$nix_path")
        set actual_perms (stat -c "%a" "$nix_path")

        print_status "Checking $nix_path: owner=$actual_owner, group=$actual_group, perms=$actual_perms"

        if test "$actual_owner" != "$expected_owner" -o "$actual_group" != "$expected_group"
            print_error "  Permission issue: expected owner:group $expected_owner:$expected_group, got $actual_owner:$actual_group"
            if test "$CAN_MAKE_CHANGES" = true
                print_status "  Fixing ownership..."
                chown "$expected_owner:$expected_group" "$nix_path"
                print_status "  Ownership fixed for $nix_path"
            else
                print_warning "  Run this script as root to fix this issue: sudo "(status filename)
            end
            return 1
        else
            print_status "  ✓ Permissions correct for $nix_path"
            return 0
        end
    else
        print_error "  Directory does not exist: $nix_path"
        if test "$CAN_MAKE_CHANGES" = true
            print_status "  Creating directory $nix_path..."
            mkdir -p "$nix_path"
            chown "$expected_owner:$expected_group" "$nix_path"
            print_status "  Directory created and permissions set"
        else
            print_warning "  Directory needs to be created. Run with sudo to create."
        end
        return 1
    end
end

# Check base Nix permissions
print_status "Checking base Nix permissions..."
check_and_fix_permissions "/nix" "root" "nixbld"

# Check and create per-user directories if needed
print_status "Checking per-user Nix directories for user: $CURRENT_USER"
set PER_USER_PROFILES "/nix/var/nix/profiles/per-user/$CURRENT_USER"
set PER_USER_GCTOOTS "/nix/var/nix/gcroots/per-user/$CURRENT_USER"

# Check parent directories
check_and_fix_permissions "/nix/var/nix/profiles/per-user" "root" "root"
if test $status -eq 0  # Only set permissions if parent directory exists
    if test "$CAN_MAKE_CHANGES" = true
        chmod 1777 "/nix/var/nix/profiles/per-user"  # Set as world-writable
        print_status "  Set permissions 1777 on /nix/var/nix/profiles/per-user"
    end
end

check_and_fix_permissions "/nix/var/nix/gcroots/per-user" "root" "root"
if test $status -eq 0  # Only set permissions if parent directory exists
    if test "$CAN_MAKE_CHANGES" = true
        chmod 1777 "/nix/var/nix/gcroots/per-user"  # Set as world-writable
        print_status "  Set permissions 1777 on /nix/var/nix/gcroots/per-user"
    end
end

# Check user-specific directories
check_and_fix_permissions "$PER_USER_PROFILES" "$CURRENT_USER" "$CURRENT_GROUP"
check_and_fix_permissions "$PER_USER_GCTOOTS" "$CURRENT_USER" "$CURRENT_GROUP"

# Check if nix develop would work by checking if we can access the flake
print_status "Checking if nix develop environment can be accessed..."
if command -v nix &> /dev/null
    print_status "  ✓ Nix command is available"

    # Check if we're in a flake directory (for testing)
    if test -f "./flake.nix" -a (basename (pwd)) = "pantherOS"
        print_status "  ✓ In a flake directory, checking if nix develop works..."
        # We can't actually run nix develop here without side effects, but we can check if the devShells exist
        if nix flake show . 2>/dev/null | grep -q "devShells"
            print_status "  ✓ Development environment is defined in flake.nix"
        else
            print_warning "  No development environment found in flake.nix"
        end
    else
        print_status "  Not in a specific flake directory, but Nix is available"
    end
else
    print_error "  Nix command is not available"
end

# Summary
print_status "Nix permissions check complete."
if test "$CAN_MAKE_CHANGES" = true
    print_status "All identified permission issues have been fixed."
else
    print_warning "Run this script with sudo to fix any permission issues that were identified."
end

print_status "To verify everything works, try running 'nix develop' in your project directory."
