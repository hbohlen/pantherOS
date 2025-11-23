# PantherOS Home Manager Modules Collection
# Aggregates all PantherOS-specific Home Manager modules using a granular, modular structure

{
  # Shell modules
  shell = import ./shell;

  # Development modules
  development = import ./development;
}
