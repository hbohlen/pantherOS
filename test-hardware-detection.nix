# Test script for hardware detection functions
{ lib }:
let
  hardwareProfiles = import ./lib/storage/hardware-profiles.nix { inherit lib; };

  # Test data from actual facter.json files
  testZephyrus = builtins.fromJSON (builtins.readFile ./hosts/zephyrus/facter.json);
  testYoga = builtins.fromJSON (builtins.readFile ./hosts/yoga/facter.json);
  testHetzner = builtins.fromJSON (builtins.readFile ./hosts/servers/hetzner-vps/facter.json);
  testContabo = builtins.fromJSON (builtins.readFile ./hosts/servers/contabo-vps/facter.json);

in
rec {
  # Test results
  zephyrusDetected = hardwareProfiles.detectZephyrus testZephyrus;
  yogaDetected = hardwareProfiles.detectYoga testYoga;
  hetznerDetected = hardwareProfiles.detectHetzner testHetzner;
  contaboDetected = hardwareProfiles.detectContabo testContabo;
  ovhDetected = hardwareProfiles.detectOVH testHetzner;  # Using hetzner as fallback test

  zephyrusProfile = hardwareProfiles.selectStorageProfile testZephyrus;
  yogaProfile = hardwareProfiles.selectStorageProfile testYoga;
  hetznerProfile = hardwareProfiles.selectStorageProfile testHetzner;
  contaboProfile = hardwareProfiles.selectStorageProfile testContabo;

  # Task 2.1: Test Zephyrus detection
  test_2_1_zephyrus_detection =
    if zephyrusDetected
    then "PASS"
    else "FAIL";

  # Task 2.2: Test Yoga detection
  test_2_2_yoga_detection =
    if yogaDetected
    then "PASS"
    else "FAIL";

  # Task 2.3: Test VPS detection
  test_2_3_hetzner_detection =
    if hetznerDetected
    then "PASS"
    else "FAIL";

  test_2_3_contabo_detection =
    if contaboDetected
    then "PASS"
    else "FAIL";

  # Task 2.4: Test profile selector
  test_2_4_zephyrus_profile =
    if zephyrusProfile == "dev-laptop"
    then "PASS"
    else "FAIL";

  test_2_4_yoga_profile =
    if yogaProfile == "light-laptop"
    then "PASS"
    else "FAIL";

  test_2_4_hetzner_profile =
    if hetznerProfile == "production-vps"
    then "PASS"
    else "FAIL";

  test_2_4_contabo_profile =
    if contaboProfile == "staging-vps"
    then "PASS"
    else "FAIL";

  # Summary
  summary = "=== Hardware Detection Test Results ===\n"
    + "Task 2.1 (Zephyrus detection): " + test_2_1_zephyrus_detection + "\n"
    + "Task 2.2 (Yoga detection): " + test_2_2_yoga_detection + "\n"
    + "Task 2.3a (Hetzner detection): " + test_2_3_hetzner_detection + "\n"
    + "Task 2.3b (Contabo detection): " + test_2_3_contabo_detection + "\n"
    + "Task 2.4a (Zephyrus profile): " + test_2_4_zephyrus_profile + " (" + zephyrusProfile + ")\n"
    + "Task 2.4b (Yoga profile): " + test_2_4_yoga_profile + " (" + yogaProfile + ")\n"
    + "Task 2.4c (Hetzner profile): " + test_2_4_hetzner_profile + " (" + hetznerProfile + ")\n"
    + "Task 2.4d (Contabo profile): " + test_2_4_contabo_profile + " (" + contaboProfile + ")\n"
    + "=== All Tests Complete ===";
}
