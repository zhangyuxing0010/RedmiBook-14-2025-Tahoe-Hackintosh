# Required kexts and downloads

No binaries are bundled here. Versions below are the ones this build was verified with (macOS Tahoe 26.7.1, 25G241).

## Graphics

| Kext | Version | Source | Notes |
|---|---|---|---|
| WhateverXe.kext | 0.8.3 (custom build) | [jkbuha/WhateverXe](https://github.com/jkbuha/WhateverXe) branch `xps-unified` | Upstream 0.8.3 + RPL-P/ADL-H eDP admission. Build with the steps below; the upstream 0.8.3 RELEASE binary does **not** pass the A7AA preflight on this board. |
| AMFIAnchor.kext / AMFIAnchorInjector.kext | 0.1.2 | Ships with WhateverXe 0.8.3 (README "AMFIAnchor setup") | Required by WhateverXe 0.8.3. |
| AppleIntelTGLCompat / AppleIntelTGLGraphics / AppleIntelTGLGraphicsFramebuffer | 0.8.1 / 16.0.0 | [WhateverXe-Graphics 0.4.4 pkg](https://github.com/b00t0x/WhateverXe-Graphics/releases/tag/v0.4.4) | Apple binaries; **install via the pkg, do not redistribute**. Reinstall after every macOS update. |

Build of the patched WhateverXe (macOS host with Xcode CLT and Python 3.9+):

```bash
git clone -b xps-unified https://github.com/jkbuha/WhateverXe
git clone https://github.com/acidanthera/MacKernelSDK
# Lilu DEBUG zip provides Contents/Resources/Headers for the build
curl -LO https://github.com/acidanthera/Lilu/releases/download/1.7.2/Lilu-1.7.2-DEBUG.zip
unzip Lilu-1.7.2-DEBUG.zip
cp -R MacKernelSDK WhateverXe/MacKernelSDK
cp -R Lilu.kext WhateverXe/Lilu.kext
cd WhateverXe && python3 tools/build.py --release
# result: build/WhateverXe.kext (sha256 8d7cf157a6855d91160833e967f73e38930e65824851ed9ea11749a148a4ff5f)
```

Boot argument required for this build: `-wex-edp-keep`.

## Wi-Fi / Bluetooth

| Kext | Version | Source |
|---|---|---|
| ForbiddenItlwm.kext | 0.6.0-beta.2, **Tahoe build** | [retropineaple/ForbiddenItlwm releases](https://github.com/retropineaple/ForbiddenItlwm/releases/tag/v0.6.0-beta.2) (`ForbiddenItlwm-0.6.0-beta.2-Tahoe.zip`) |
| BTLEAdvFixup.kext | 0.9.3, **Tahoe build** | same release (`BTLEAdvFixup-0.9.3-Tahoe.zip`) |
| IntelBluetoothFirmware.kext | 2.5.0 | [OpenIntelWireless/IntelBluetoothFirmware](https://github.com/OpenIntelWireless/IntelBluetoothFirmware) |
| BlueToolFixup.kext | 2.7.3 | [acidanthera/BrcmPatchRAM](https://github.com/acidanthera/BrcmPatchRAM) |
| IntelBTPatcher.kext | 2.5.0 | OpenIntelWireless — **disable it**, BTLEAdvFixup takes over its hook |

ForbiddenItlwm needs the full AWDL boot-arg set from its `docs/BOOT-FLAGS.md`; the set used here is in the main README.

## Audio

| Kext | Version | Source |
|---|---|---|
| AppleALC.kext | 1.9.x | [acidanthera/AppleALC](https://github.com/acidanthera/AppleALC) |
| SimpleHDA.kext | 1.0.1 (Tahoe) | [laobamac/SimpleHDA](https://github.com/laobamac/SimpleHDA) — restores AppleHDA on Tahoe |

`SimpleHDA` is required on Tahoe because the system no longer ships `AppleHDA.kext`; it must be loaded **after** AppleALC. Requires `Kernel > Quirks > DisableLinkeditJettison = true` (already set in this config).

## Input

| Kext | Version | Source |
|---|---|---|
| VoodooPS2Controller.kext | 2.3.8 | [acidanthera/VoodooPS2](https://github.com/acidanthera/VoodooPS2) |
| VoodooI2C.kext / VoodooI2CHID.kext / VoodooGPIO / VoodooI2CServices | 2.9.1 / 1 / 1.1 | [VoodooI2C/VoodooI2C](https://github.com/VoodooI2C/VoodooI2C) |
| VoodooInput.kext | 1.1.7 | [acidanthera/VoodooInput](https://github.com/acidanthera/VoodooInput) |

## Core

| Kext | Version | Source |
|---|---|---|
| Lilu.kext | 1.7.3 | [acidanthera/Lilu](https://github.com/acidanthera/Lilu) |
| VirtualSMC.kext + SMCProcessor / SMCSuperIO / SMCBatteryManager / SMCLightSensor | 1.3.x | [acidanthera/VirtualSMC](https://github.com/acidanthera/VirtualSMC) |
| USBToolBox.kext + UTBDefault.kext | 1.x | [USBToolBox](https://github.com/USBToolBox/kext) |
| NVMeFix.kext | 1.1.x | [acidanthera/NVMeFix](https://github.com/acidanthera/NVMeFix) |
| RestrictEvents.kext | 1.1.x | [acidanthera/RestrictEvents](https://github.com/acidanthera/RestrictEvents) |
| BrightnessKeys.kext | 1.0.x | [acidanthera/BrightnessKeys](https://github.com/acidanthera/BrightnessKeys) |

## OpenCore drivers

`OpenRuntime.efi`, `HfsPlus.efi`, `OpenCanopy.efi`, `ResetNvramEntry.efi`, `apfs_aligned.efi` — from [OpenCorePkg](https://github.com/acidanthera/OpenCorePkg/releases).
