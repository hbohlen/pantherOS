# Test file to validate module syntax
let
  # Test importing the main module aggregation
  mainModules = import ./default.nix;
  
  # Test importing core modules
  coreModules = import ./core/default.nix;
  
  # Test importing services modules
  serviceModules = import ./services/default.nix;
  
  # Test importing security modules
  securityModules = import ./security/default.nix;
in
{
  # Return the module structures to validate they can be imported
  main = mainModules;
  core = coreModules;
  services = serviceModules;
  security = securityModules;
}