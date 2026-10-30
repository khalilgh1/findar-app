---
name: run-findar
description: Launch the Findar Flutter app on the local Android emulator (wamid_pixel) on this Windows machine, including emulator boot, build gotchas, and how to see/drive the running app. Use when asked to run, start, screenshot, or manually verify the app.
---

# Run Findar on the Android emulator

Windows host. Android SDK at `C:\Android` (not the default `%LOCALAPPDATA%`). Flutter at `C:\Users\omen\flutter`. Use the PowerShell tool for long-running/background commands.

## 1. Boot the emulator

```powershell
adb devices                          # already "emulator-5554  device"? skip to step 2
flutter emulators --launch wamid_pixel
```

Wait until `adb shell getprop sys.boot_completed` returns `1` (poll every 5 s, up to ~4 min).

If the device stays `offline` and `qemu-system-x86_64` uses almost no CPU, it's hung on a snapshot. Cold-boot:

```powershell
Get-Process qemu*,emulator* -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Process C:\Android\emulator\emulator.exe -ArgumentList "-avd wamid_pixel -no-snapshot-load"
```

## 2. Build and run

```powershell
Set-Location findar_app
flutter run -d emulator-5554 *> <scratchpad>\flutter_run.log     # run_in_background: true
```

Then wait for `key commands` (success) or `BUILD FAILED|Error:` in the log. Cold build ≈ 3–5 min; incremental ≈ 1 min. Default API is production (`https://findar-app.onrender.com`; Render free tier may take ~30–60 s to wake). For a local backend add `--dart-define=API_BASE_URL=http://10.0.2.2:8000`.

## 3. See / drive it

- Screenshot: `adb exec-out screencap -p > <scratchpad>/screen.png`, then Read the PNG. **Look at it** — a blank frame means it didn't render.
- Interact: prefer the `mobile-mcp` MCP tools (tap/type/swipe/accessibility tree). Fallback: `adb shell input tap X Y` (coords in 1080x2400 device pixels), `adb shell input text "..."`.
- First launch shows the Android notification-permission dialog.
- Logs: the flutter run log, or `adb logcat -s flutter`.

## Known build failures

| Symptom | Cause / fix |
|---|---|
| `Could not determine the dependencies of task ':firebase_core:compileDebugJavaWithJavac'` → `Cannot query the value of this provider` | `C:\Android\platforms\android-34\android.jar` missing (firebase plugins compile against SDK 34). Reinstall: `C:\Android\cmdline-tools\latest\bin\sdkmanager.bat --sdk_root=C:\Android "platforms;android-34"` |
| `Inconsistent JVM-target compatibility … (17) and … (1.8)` | `android/app/build.gradle` `kotlinOptions.jvmTarget` must match `compileOptions` (17) |
| `No such host is known (repo.maven.apache.org)` | Transient DNS on this network — just retry |
| Warnings that AGP 8.11 / Gradle 8.14 / Kotlin 2.2.20 support "will soon be dropped" | Non-fatal; upgrading is tracked in docs/roadmap.md |
