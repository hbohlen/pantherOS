function attic-setup-1password --description 'Setup Attic with credentials from 1Password'
    if not type -q op
        echo "Error: 1Password CLI (op) not found"
        return 1
    end

    if not type -q attic
        echo "Error: attic not found. Installing..."
        nix profile install nixpkgs#attic-client
    end

    echo "Loading Backblaze B2 credentials from 1Password..."
    
    # Load credentials from 1Password
    set -gx BACKBLAZE_KEY_ID (op read "op://pantherOS/Backblaze-B2/key_id" 2>/dev/null)
    set -gx BACKBLAZE_SECRET_KEY (op read "op://pantherOS/Backblaze-B2/secret_key" 2>/dev/null)

    if test -z "$BACKBLAZE_KEY_ID" -o -z "$BACKBLAZE_SECRET_KEY"
        echo "Error: Failed to load credentials from 1Password"
        echo "Make sure the item 'Backblaze-B2' exists in the 'pantherOS' vault"
        echo "with fields 'key_id' and 'secret_key'"
        return 1
    end

    echo "✓ Credentials loaded successfully"
    echo "✓ BACKBLAZE_KEY_ID set"
    echo "✓ BACKBLAZE_SECRET_KEY set"
    echo ""
    echo "You can now use attic commands:"
    echo "  attic cache info pantherOS"
    echo "  attic push pantherOS <path>"
end
