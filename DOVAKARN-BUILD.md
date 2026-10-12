# Building Dovakarn's TrueHUD.dll

Branch `dovakarn/1.1.9-head-anchor` (from `dovakarn/1.1.9-lift-bars`, from TrueHUD 1.1.9 `2c7232f`). What it adds, all
in the floating info bar (`src/Widgets/ActorInfoBar.cpp`), the boss bar untouched:

- **`uInfoBarAnchor = 2`** (`WidgetAnchor::kHeadNode`): the bar is placed at the `NPC Head [Head]` node's world position
  plus `fInfoBarOffsetZ`, instead of `GetLookingAtLocation()`. Dovakarn's name plates are laid out from that node, and the
  looking-at point sits elsewhere by an amount that changes with the camera's angle, so the two drifted apart. An actor
  without that node falls back to the looking-at point.
- **`fInfoBarMaxDistance`** (game units, 0 = off) and **`bInfoBarRequireLineOfSight`**: a bar whose actor is further
  from the player, or out of the player's line of sight (asked at most every 0.12 s per bar), is hidden, not removed, and
  shows again once back in range and sight while TrueHUD still wants it. Both are off by default; a build with
  `-DTRUEHUD_DOVAKARN_DEFAULTS=ON` defaults them to 1000 and on (Dovakarn's, as its settings file cannot carry new keys).
  They can also be set in the `[ActorInfoBars]` section of the settings files.
- The `TrueHUD.esl` globals are also looked up as `TrueHUD.esp`, for load orders that load the plugin as an ESP.

## Build used by Dovakarn

- CommonLibSSE-NG: https://github.com/alandtse/CommonLibVR branch `ng` at `cab9f743f` ("fix: fix playercharacter and
  controlmap offsets", 24/12/2023), in `CommonLibSSEPath_NG`. It must be this commit or later: the commit before it
  (`d970ed21ea`) reads ControlMap's runtime data at 0xE8 on every AE build, but Skyrim 1.6.1130 and later have it at
  0xF0, and a DLL built on it crashes at the first menu (HUDHandler::ProcessEvent(MenuOpenCloseEvent), the
  contextPriorityStack read). TrueHUD 1.1.9's own DLL reads it as `cab9f743f` does (0xF0 from 1.6.1130).
- vcpkg `cb2981c4e03d421fa03b9bb5044cd1986180e7e4`, triplet `x64-windows-static`, static C runtime (so the DLL does not
  depend on the player's Visual C++ runtime version).
- Visual Studio 2026 (MSVC 14.51), CMake from Visual Studio:

```
cmake -S . -B build-mt -G "Visual Studio 18 2026" -A x64 ^
  -DCMAKE_TOOLCHAIN_FILE=%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake -DVCPKG_TARGET_TRIPLET=x64-windows-static ^
  "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded$<$<CONFIG:Debug>:Debug>" "-DCMAKE_CXX_FLAGS=/EHsc /MP /W4" ^
  -DCOPY_OUTPUT=OFF -DTRUEHUD_DOVAKARN_DEFAULTS=ON
cmake --build build-mt --config Release
```

The widget it pairs with is `swf/ffdec/BUILD.md`'s `TrueHUD_Widgets.swf` (its ActionScript calls are unchanged).
The sha256 of the DLL Dovakarn serves is in its commit message on this branch and in Dovakarn's player file list.
