# Known issues on this machine

These are hardware trust-root or DRM limits, not configuration mistakes. They were each verified with logs before being written down.

## Internal microphone — not drivable by macOS

The built-in mics are PDM digital microphones wired to the Intel Smart Sound DSP, not to the ALC256 codec ADC. Evidence:

- Windows device tree: `INTELAUDIO\...&VEN_8086&DEV_AE20&SUBSYS_1D722413` = "Intel Smart Sound Technology for Digital Microphone" (`IntcDMic`).
- macOS exposes a phantom `Built-in Input / Internal Microphone` (generic AppleHDA path) that records only a constant DC level (~294/32768), regardless of `ChannelMode` or `alcid`.
- AppleALC layouts cannot help: there is no analog mic on the codec.

Experimented with [TGLDmic](https://github.com/labrouss/TGLDmic) (SOF firmware on cAVS). With two local patches (`0x51CA` PCI ID + tolerating a non-latching `SD_CTL.SRST`) the DSP boots (`BootResult = OK FW_READY`) and the capture IPC chain completes, but no DMIC data arrives — the NHLT/DMIC link on this board differs from the tested ADL-P reference. Reported upstream in `labrouss/TGLDmic` PR #2.

**Workaround:** USB microphone or Bluetooth headset mic.

## Apple Music streaming — FairPlay DRM fails on Tahoe

Local files play, Safari plays, but Apple Music streaming fails with:

```
[com.apple.coremedia:DRM] Key request data generation FAILED
AVFoundationErrorDomain -11800 status -15842
ICSecureKeyDeliveryRequestOperation: [SKD] Failed to generate server playback context data (ICError -7101)
```

The same account and machine streamed fine on Sequoia 15.8.1. Tahoe's FairPlay path needs a device attestation this hackintosh cannot provide. Network was ruled out (Wi-Fi and iPhone tether both fail; ordinary Apple traffic works).

## Fingerprint — FPC sensor, no macOS support

USB device: `FPC Sensor Controller L:0001 FW:021.26.2.056`, vendor `10A5`, product `9201`.

macOS has no generic fingerprint API. Touch ID on real Macs goes through the Secure Enclave (T1/T2/SEP) since the very first Touch Bar Mac (2016, T1), so there is no path to hand an FPC result to login/unlock. A kext could read the sensor, but nothing in macOS would trust it.

## iPhone Mirroring — requires Apple silicon or T2

`iPhone Mirroring.app` fails at authentication (`ScreenSharingKit.RemoteAuthenticationError Code=3`) because there is no Secure Enclave to attest the pairing. Not fixable by SMBIOS spoofing.

## 120 Hz refresh rate

The panel is 2880×1800 @ 120 Hz capable but the machine runs at 60 Hz. Selecting 120 Hz on Sequoia produced a black screen (the setting is stored in `~/Library/Preferences/ByHost/com.apple.windowserver.*.plist` and `/Library/Preferences/com.apple.windowserver.plist`; delete both to recover). Not retested on Tahoe.

## Touchpad

Goodix I2C HID. GPIO/APIC interrupt mode drops touches ("断触") on this board, so the build uses `-vi2c-force-polling`. Polling is stable but may feel slightly less smooth.

## Camera

Works once Metal is available. Photo Booth preview is a `CAMetalLayer`; without Metal it is black and the shutter cannot save.
