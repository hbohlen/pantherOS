# Tasks: Add Zed IDE

## Implementation Plan

1. **Add Zed flake input to flake.nix**
   - Add zed-industries/zed as a flake input
   - Verify the input builds correctly
   - Test: `nix flake lock --update-input zed`

2. **Create Zed Home Manager module**
   - Create `modules/home/zed.nix` with Zed package installation
   - Import the module in personal device configurations
   - Test: Build personal device configuration

3. **Update personal device configurations**
   - Add Zed module to zephyrus and yoga host configurations
   - Ensure Zed is available in user environment
   - Test: Deploy to personal device and verify Zed launches

4. **Validate Zed functionality**
   - Test Zed launches successfully
   - Verify basic editing functionality works
   - Test: Run `zed --version` and open a file</content>
     <parameter name="filePath">openspec/changes/add-zed-ide/tasks.md
