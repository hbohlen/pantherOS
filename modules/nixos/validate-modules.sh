#!/usr/bin/env bash

# Simple validation script to check syntax of Nix modules

echo "Validating Nix module syntax..."

# Change to the modules directory
cd "$(dirname "$0")"

# Test the main modules aggregation using nix-instantiate with proper path
echo "Testing main module aggregation..."
echo '{ ... }: import ./default.nix' > temp_test.nix
nix-instantiate --eval --strict --argstr self "$(pwd)" temp_test.nix 2>/dev/null || echo "Main module aggregation has errors"
rm -f temp_test.nix

# Alternative approach using nix eval for better error reporting
echo "Testing main module aggregation with nix eval..."
if nix eval --file ./default.nix --impure --expr 'builtins.attrNames (import ./default.nix {})' 2>/dev/null; then
  echo "✓ Main module aggregation syntax is valid"
else
  echo "✗ Main module aggregation has syntax errors"
fi

# Test core modules
echo "Testing core modules..."
if nix eval --file ./core/default.nix --impure --expr 'builtins.attrNames (import ./core/default.nix {})' 2>/dev/null; then
  echo "✓ Core module aggregation syntax is valid"
else
  echo "✗ Core module aggregation has syntax errors"
fi

# Test individual core submodules
echo "Testing core users modules..."
if nix eval --file ./core/users/default.nix --impure --expr 'builtins.attrNames (import ./core/users/default.nix {})' 2>/dev/null; then
  echo "✓ Core users module aggregation syntax is valid"
else
  echo "✗ Core users module aggregation has syntax errors"
fi

echo "Testing core system modules..."
if nix eval --file ./core/system/default.nix --impure --expr 'builtins.attrNames (import ./core/system/default.nix {})' 2>/dev/null; then
  echo "✓ Core system module aggregation syntax is valid"
else
  echo "✗ Core system module aggregation has syntax errors"
fi

# Test service modules
echo "Testing services modules..."
if nix eval --file ./services/default.nix --impure --expr 'builtins.attrNames (import ./services/default.nix {})' 2>/dev/null; then
  echo "✓ Services module aggregation syntax is valid"
else
  echo "✗ Services module aggregation has syntax errors"
fi

# Test individual service submodules
echo "Testing services networking modules..."
if nix eval --file ./services/networking/default.nix --impure --expr 'builtins.attrNames (import ./services/networking/default.nix {})' 2>/dev/null; then
  echo "✓ Services networking module aggregation syntax is valid"
else
  echo "✗ Services networking module aggregation has syntax errors"
fi

# Test security modules
echo "Testing security modules..."
if nix eval --file ./security/default.nix --impure --expr 'builtins.attrNames (import ./security/default.nix {})' 2>/dev/null; then
  echo "✓ Security module aggregation syntax is valid"
else
  echo "✗ Security module aggregation has syntax errors"
fi

# Test individual security submodules
echo "Testing security firewall modules..."
if nix eval --file ./security/firewall/default.nix --impure --expr 'builtins.attrNames (import ./security/firewall/default.nix {})' 2>/dev/null; then
  echo "✓ Security firewall module aggregation syntax is valid"
else
  echo "✗ Security firewall module aggregation has syntax errors"
fi

echo "Syntax validation complete!"