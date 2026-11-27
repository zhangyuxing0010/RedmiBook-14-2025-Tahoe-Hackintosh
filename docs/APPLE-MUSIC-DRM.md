# Apple Music streaming on Tahoe (FairPlay fix)

Streaming in Music.app fails on this machine with `-disablegfxfirmware` (required by WhateverXe):

```
AVD Error: Gen75IntelGVAGetDriverParameter: ME not loaded
GVA error: flow_KE1 getParam 7
Key request data generation FAILED because we were unable to generate a key (err = -15842)
```

Local files play, and the same account streams fine in a browser (Widevine). This is not a network or audio problem.

## Root cause

AppleGVA offers a hardware FairPlay key-exchange path (`flow_KE1`) through the TGL VA driver bundle (`/Library/GPUBundles/AppleIntelTGLGraphicsVADriver.bundle`). With `-disablegfxfirmware` the media engine is not loaded, so that path cannot complete and CoreMedia DRM never falls back on its own.

Same finding, with experiments, in [b00t0x/WhateverXe#48](https://github.com/b00t0x/WhateverXe/issues/48): if AppleGVA does not see the VA driver at all, it does not advertise `ke1`, and FairPlay uses its software path. Lossless streaming then plays with sound.

## Fix: start Music in a sandbox that hides the VA driver bundle

`/Library/GPUBundles` stays untouched, so every other app keeps hardware video decoding; only the Music process is affected.

`extras/music-novagva.sb`:

```
(version 1)
(allow default)
(deny file-read* file-map-executable (subpath "/Library/GPUBundles/AppleIntelTGLGraphicsVADriver.bundle"))
```

Launch:

```bash
sandbox-exec -f extras/music-novagva.sb /System/Applications/Music.app/Contents/MacOS/Music
```

`extras/build-app.sh` builds a small launcher app (`~/Applications/音乐.app`, display name "音乐", the stock Music icon) whose executable is:

```bash
#!/bin/sh
PROFILE="$HOME/Library/Application Support/AppleMusicFix/music-novagva.sb"
if pgrep -f "/System/Applications/Music.app/Contents/MacOS/Music" >/dev/null 2>&1; then
  exec /usr/bin/osascript -e 'tell application "Music" to activate'
fi
exec /usr/bin/sandbox-exec -f "$PROFILE" /System/Applications/Music.app/Contents/MacOS/Music
```

Double-click it, or keep it in the Dock.

## Caveats

- Music must be **fully quit (⌘Q)** before using the launcher; if an instance started from the normal icon is already running, the launcher only brings it forward.
- Inside this Music process, hardware video decoding is unavailable (music videos fall back to software). Other apps are unaffected.
- Browsers (Safari with FairPlay, Chromium with Widevine) work without any of this; the launcher exists to keep the native Music app and its Liquid Glass UI.
