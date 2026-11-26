# Tahoe 26 notes (upgrading from Sequoia 15.8.1)

This machine was upgraded **in place** from Sequoia 15.8.1 (24H32) to Tahoe 26.7.1 (25G241). Everything below was learned during that upgrade.

## 1. Reinstall WhateverXe Graphics after the upgrade

After the OS upgrade, `/Library/Extensions` still had the old `AppleIntelTGL*` kexts but the Auxiliary Kernel Collection had been rebuilt for the new OS, so the framebuffer never started. Symptom with the patched WhateverXe enabled:

- Apple logo appears, then a **black screen**;
- or OpenCore halts with `Image Kexts\WhateverXe.kext\Contents\MacOS\WhateverXe is missing` if the kext folder is incomplete.

Fix: install `WhateverXe-Graphics-0.4.4.pkg` again on Tahoe (it rebuilds AuxKC), then reboot.

## 2. Wi-Fi needs the Tahoe build

`ForbiddenItlwm` and `BTLEAdvFixup` are built per macOS family. A Sequoia build on Tahoe simply does not load (no Wi-Fi port at all). Use the `*-Tahoe.zip` assets and limit the config entries by kernel version:

```
ForbiddenItlwm.kext        MinKernel 24.0.0  MaxKernel 24.99.99
ForbiddenItlwm-Tahoe.kext  MinKernel 25.0.0  MaxKernel 25.99.99
BTLEAdvFixup.kext          MinKernel 21.0.0  MaxKernel 24.99.99
BTLEAdvFixup-Tahoe.kext    MinKernel 25.0.0  MaxKernel 25.99.99
```

## 3. Tahoe has no `AppleHDA.kext`

`ls /System/Library/Extensions | grep -i hda` shows only `AppleGFXHDA.kext`. Without AppleHDA there is no audio device at all. Install [SimpleHDA](https://github.com/laobamac/SimpleHDA) 1.0.1 (Tahoe build), placed **after** AppleALC, with `Kernel > Quirks > DisableLinkeditJettison = true`.

After that, `内建输出 / 内建输入` appear again and the ALC256 layout from `DeviceProperties` (`PciRoot(0x0)/Pci(0x1f,0x3)`, `layout-id = 14`) is used.

## 4. Shutdown patch is applied, but the GPU driver stalls

`SSDT-PTSWAK.aml` plus these ACPI patches survive the upgrade (the DSDT byte patterns were verified against this machine's own dump), but they are **not enough**: shutdown still hangs in the GPU driver, see `docs/KNOWN-ISSUES.md`:

```
_PTS rename: Find 5F50545301 -> Replace 5A50545301   (Method, NotSerialized)
_WAK rename: Find 5F57414B09 -> Replace 5A57414B09   (Method, Serialized)
```

The byte patterns were verified against this machine's own DSDT (dumped with Hackintool). `_TTS` is absent in this DSDT, so no rename is needed.

## 5. Wi-Fi can be off after a reboot

After the upgrade it happened that `en0` was up but unassociated while all traffic went over an iPhone USB tether. Check `networksetup -getairportpower en0`; if it is off, turn it on:

```bash
networksetup -setairportpower en0 on
```

## 6. Boot arguments that matter

- `-wex-edp-keep` — keep the patched WhateverXe's eDP handoff alive; without it the panel goes black.
- `-vi2c-force-polling` — the Goodix touchpad reports dropped touches in GPIO/APIC mode on this board; polling is stable.
- `-disablegfxfirmware` — required by WhateverXe; note it leaves the media engine (ME) unloaded, so `AppleGVA` logs `ME not loaded` (harmless for graphics).
