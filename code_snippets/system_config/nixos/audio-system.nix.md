# Audio System Module

## Enrichment Metadata
- **Purpose**: Configure PipeWire audio system for professional audio quality and device management
- **Layer**: modules/hardware/audio
- **Dependencies**: PipeWire, WirePlumber, ALSA, PulseAudio compatibility layer
- **Conflicts**: PulseAudio standalone, JACK standalone
- **Platforms**: x86_64-linux, aarch64-linux

## Configuration Points
- `services.pipewire.enable`: Enable PipeWire audio server
- `services.pipewire.alsa.enable`: Enable ALSA compatibility
- `services.pipewire.pulse.enable`: Enable PulseAudio compatibility
- `services.pipewire.jack.enable`: Enable JACK compatibility
- `hardware.pulseaudio.enable`: Must be disabled when using PipeWire
- `security.rtkit.enable`: Enable real-time kit for low-latency audio
- `sound.enable`: Enable sound support

## Code

```nix
# modules/hardware/audio/pipewire.nix
{ config, lib, pkgs, ... }:

let
  cfg = config.pantherOS.hardware.audio;
in
{
  options.pantherOS.hardware.audio = {
    enable = lib.mkEnableOption "Advanced PipeWire audio system";
    
    # Audio quality profile
    quality = lib.mkOption {
      type = lib.types.enum [ "standard" "high" "professional" ];
      default = "standard";
      description = ''
        Audio quality profile:
        - standard: Default settings for general use
        - high: Enhanced quality for music and media
        - professional: Low-latency settings for audio production
      '';
    };
    
    # Sample rate configuration
    sampleRate = lib.mkOption {
      type = lib.types.int;
      default = 48000;
      description = "Default sample rate for audio playback";
    };
    
    # Buffer size for low-latency
    bufferSize = lib.mkOption {
      type = lib.types.int;
      default = 1024;
      description = "Buffer size in samples (lower = less latency, higher CPU usage)";
    };
    
    # Enable specific features
    features = {
      bluetooth = lib.mkEnableOption "Bluetooth audio support (A2DP, HSP/HFP)";
      jack = lib.mkEnableOption "JACK audio server compatibility";
      lowLatency = lib.mkEnableOption "Low-latency audio configuration";
      noiseCancellation = lib.mkEnableOption "Noise cancellation for microphones";
      echoCancellation = lib.mkEnableOption "Echo cancellation for voice calls";
    };
    
    # Device management
    devices = {
      preferredSink = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of preferred audio output device";
        example = "alsa_output.pci-0000_00_1f.3.analog-stereo";
      };
      
      preferredSource = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Name of preferred audio input device";
        example = "alsa_input.pci-0000_00_1f.3.analog-stereo";
      };
    };
  };
  
  config = lib.mkIf cfg.enable {
    # Disable PulseAudio (conflicts with PipeWire)
    hardware.pulseaudio.enable = false;
    
    # Enable sound support
    sound.enable = true;
    
    # Enable real-time scheduling for audio
    security.rtkit.enable = true;
    
    # PipeWire configuration
    services.pipewire = {
      enable = true;
      
      # ALSA support
      alsa = {
        enable = true;
        support32Bit = true;
      };
      
      # PulseAudio compatibility layer
      pulse.enable = true;
      
      # JACK compatibility
      jack.enable = cfg.features.jack;
      
      # WirePlumber session manager configuration
      wireplumber = {
        enable = true;
        
        # Custom configuration files
        configPackages = [
          (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-audio-quality.conf" ''
            monitor.alsa.rules = [
              {
                matches = [
                  {
                    node.name = "~alsa_.*"
                  }
                ]
                actions = {
                  update-props = {
                    ${if cfg.quality == "professional" then ''
                      audio.format = "S32LE"
                      audio.rate = ${toString cfg.sampleRate}
                      api.alsa.period-size = ${toString (cfg.bufferSize / 2)}
                      api.alsa.headroom = 512
                    '' else if cfg.quality == "high" then ''
                      audio.format = "S24LE"
                      audio.rate = ${toString cfg.sampleRate}
                      api.alsa.period-size = ${toString cfg.bufferSize}
                      api.alsa.headroom = 1024
                    '' else ''
                      audio.format = "S16LE"
                      audio.rate = ${toString cfg.sampleRate}
                      api.alsa.period-size = ${toString cfg.bufferSize}
                      api.alsa.headroom = 2048
                    ''}
                  }
                }
              }
            ]
          '')
          
          # Bluetooth audio configuration
          (lib.mkIf cfg.features.bluetooth (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/20-bluetooth.conf" ''
            monitor.bluez.properties = {
              bluez5.enable-sbc-xq = true
              bluez5.enable-msbc = true
              bluez5.enable-hw-volume = true
              bluez5.roles = [ hsp_hs hsp_ag hfp_hf hfp_ag ]
            }
            
            monitor.bluez.rules = [
              {
                matches = [
                  {
                    device.name = "~bluez_.*"
                  }
                ]
                actions = {
                  update-props = {
                    bluez5.auto-connect = [ hfp_hf hsp_hs a2dp_sink ]
                    bluez5.hw-volume = [ hfp_hf hsp_hs a2dp_sink ]
                  }
                }
              }
            ]
          ''))
          
          # Noise and echo cancellation
          (lib.mkIf (cfg.features.noiseCancellation || cfg.features.echoCancellation) (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/30-cancellation.conf" ''
            monitor.alsa.rules = [
              {
                matches = [
                  {
                    node.name = "~alsa_input.*"
                  }
                ]
                actions = {
                  update-props = {
                    ${lib.optionalString cfg.features.noiseCancellation ''
                      filter.graph = {
                        nodes = [
                          {
                            type = ladspa
                            name = noise_suppressor
                            plugin = ${pkgs.rnnoise-plugin}/lib/ladspa/librnnoise_ladspa.so
                            label = noise_suppressor_mono
                          }
                        ]
                      }
                    ''}
                    ${lib.optionalString cfg.features.echoCancellation ''
                      aec.method = webrtc
                      aec.args = {
                        analog_gain_control = false
                        digital_gain_control = true
                        noise_suppression = true
                      }
                    ''}
                  }
                }
              }
            ]
          ''))
          
          # Low-latency configuration
          (lib.mkIf cfg.features.lowLatency (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/40-low-latency.conf" ''
            monitor.alsa.rules = [
              {
                matches = [
                  {
                    node.name = "~alsa_.*"
                  }
                ]
                actions = {
                  update-props = {
                    api.alsa.period-size = ${toString (cfg.bufferSize / 4)}
                    api.alsa.headroom = 0
                    session.suspend-timeout-seconds = 0
                  }
                }
              }
            ]
          ''))
          
          # Preferred devices
          (lib.mkIf (cfg.devices.preferredSink != null || cfg.devices.preferredSource != null) (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/50-preferred-devices.conf" ''
            ${lib.optionalString (cfg.devices.preferredSink != null) ''
              default.configured.audio.sink = ${cfg.devices.preferredSink}
            ''}
            ${lib.optionalString (cfg.devices.preferredSource != null) ''
              default.configured.audio.source = ${cfg.devices.preferredSource}
            ''}
          ''))
        ];
      };
    };
    
    # Audio packages and utilities
    environment.systemPackages = with pkgs; [
      # PipeWire control utilities
      pavucontrol          # PulseAudio Volume Control (works with PipeWire)
      helvum               # PipeWire patchbay
      qpwgraph             # Qt-based PipeWire graph manager
      
      # Audio testing and monitoring
      alsa-utils           # ALSA utilities (alsamixer, aplay, arecord)
      pulseaudio           # Command-line tools (pactl, pacmd)
      
      # Audio format support
      libsndfile           # Audio file format support
      
      # Codec support
      ffmpeg-full          # Comprehensive codec support
      
      # Bluetooth audio (if enabled)
    ] ++ lib.optionals cfg.features.bluetooth [
      bluez                # Bluetooth protocol stack
      bluez-tools          # Bluetooth utilities
    ] ++ lib.optionals cfg.features.noiseCancellation [
      rnnoise-plugin       # Real-time noise suppression
    ] ++ lib.optionals cfg.features.jack [
      qjackctl             # JACK control utility
      jack2                # JACK audio connection kit
    ];
    
    # Bluetooth support for audio devices
    hardware.bluetooth = lib.mkIf cfg.features.bluetooth {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };
    
    # User groups for audio access
    users.users = lib.mapAttrs (name: user: {
      extraGroups = [ "audio" "pipewire" ];
    }) config.users.users;
  };
}
```

## Usage Examples

### Basic Audio Setup
```nix
{
  pantherOS.hardware.audio = {
    enable = true;
    quality = "standard";
  };
}
```

### High-Quality Audio for Music Production
```nix
{
  pantherOS.hardware.audio = {
    enable = true;
    quality = "professional";
    sampleRate = 96000;
    bufferSize = 256;
    features = {
      jack = true;
      lowLatency = true;
    };
  };
}
```

### Audio for Video Conferencing
```nix
{
  pantherOS.hardware.audio = {
    enable = true;
    quality = "high";
    features = {
      noiseCancellation = true;
      echoCancellation = true;
      bluetooth = true;
    };
  };
}
```

### Specific Device Configuration
```nix
{
  pantherOS.hardware.audio = {
    enable = true;
    devices = {
      preferredSink = "alsa_output.usb-Focusrite_Scarlett_2i2_USB-00.analog-stereo";
      preferredSource = "alsa_input.usb-Focusrite_Scarlett_2i2_USB-00.analog-stereo";
    };
  };
}
```

## Integration Examples

### Laptop Audio with Bluetooth
```nix
{
  # Audio system
  pantherOS.hardware.audio = {
    enable = true;
    quality = "high";
    features = {
      bluetooth = true;
      noiseCancellation = true;
    };
  };
  
  # Bluetooth configuration
  hardware.bluetooth.enable = true;
}
```

### Professional Audio Workstation
```nix
{
  pantherOS.hardware.audio = {
    enable = true;
    quality = "professional";
    sampleRate = 192000;
    bufferSize = 128;
    features = {
      jack = true;
      lowLatency = true;
    };
  };
  
  # Additional audio production tools
  environment.systemPackages = with pkgs; [
    ardour
    audacity
    lmms
    guitarix
  ];
}
```

## Troubleshooting

### Check Audio Status
```bash
# List PipeWire devices
pw-cli list-objects Node

# Check audio sinks and sources
pactl list sinks
pactl list sources

# Monitor audio graph
pw-top

# Check Bluetooth audio devices
bluetoothctl devices
```

### Common Issues

#### No Audio Output
1. Check that PipeWire is running:
   ```bash
   systemctl --user status pipewire pipewire-pulse
   ```

2. Verify sound card is detected:
   ```bash
   aplay -l
   ```

3. Check volume levels:
   ```bash
   alsamixer
   pavucontrol
   ```

#### Bluetooth Audio Not Working
1. Enable Bluetooth service:
   ```bash
   systemctl enable bluetooth
   systemctl start bluetooth
   ```

2. Pair and connect device:
   ```bash
   bluetoothctl
   > power on
   > agent on
   > scan on
   > pair <device_mac>
   > trust <device_mac>
   > connect <device_mac>
   ```

3. Switch audio profile:
   ```bash
   pactl set-card-profile bluez_card.<device> a2dp_sink
   ```

#### Crackling or Distorted Audio
1. Increase buffer size:
   ```nix
   bufferSize = 2048;  # or higher
   ```

2. Disable low-latency mode if enabled

3. Check CPU usage and system load

#### Microphone Not Working
1. Check input device:
   ```bash
   pactl list sources short
   ```

2. Set default source:
   ```bash
   pactl set-default-source <source_name>
   ```

3. Adjust input gain:
   ```bash
   pactl set-source-volume <source_name> 50%
   ```

## Performance Considerations

### Quality vs. CPU Usage
- **Standard**: Balanced performance, suitable for most users
- **High**: Better quality, moderate CPU usage increase
- **Professional**: Best quality, highest CPU usage

### Latency Settings
- Lower buffer sizes reduce latency but increase CPU usage
- For gaming and video: 512-1024 samples
- For audio production: 128-256 samples
- For general use: 1024-2048 samples

### Sample Rate Selection
- 44100 Hz: CD quality, lowest CPU usage
- 48000 Hz: Standard digital audio, good balance
- 96000 Hz: High-resolution audio, higher CPU usage
- 192000 Hz: Professional mastering, highest CPU usage

## Security Considerations

1. **User Permissions**: Users must be in `audio` group
2. **Real-time Priority**: RTKit provides controlled real-time access
3. **Device Access**: Audio devices accessible to `audio` group members
4. **Bluetooth Security**: Use pairing and encryption for wireless audio

## TODO
- [ ] Add support for multi-channel audio configurations
- [ ] Implement automatic device switching profiles
- [ ] Add support for USB audio interface-specific optimizations
- [ ] Create audio routing templates for common scenarios
- [ ] Add integration with system volume keys and OSD
