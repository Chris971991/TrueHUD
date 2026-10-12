# TrueHUD (Dovakarn fork)

This is a fork of [ersh1/TrueHUD](https://github.com/ersh1/TrueHUD) by ersh, under the same GPL-3.0 licence (see
COPYING and EXCEPTIONS). All credit for TrueHUD goes to its author.

Branch `dovakarn/1.1.9-lift-bars` starts from TrueHUD 1.1.9 (commit 2c7232f) and changes one thing, used by the
Dovakarn Skyrim Together server for the floating health bar above characters:

- **The floating info bar lifts itself while stamina and magicka bars show under it.** TrueHUD slides those bars out
  under the health bar; the whole bar (health, indicator, name and damage counter) now moves up by exactly their height
  (the stamina bar alone 6, both 9, the same offsets TrueHUD already uses for the damage counter), so the lowest bar
  shown keeps the same small gap above the character's head as the health bar alone. Without it the lower bars sat
  down on helmets and quivers. The boss bar is unchanged.
- **Branch `dovakarn/1.1.9-head-anchor`** adds, in the plugin: `uInfoBarAnchor = 2`, the bar at the `NPC Head [Head]`
  node (the point Dovakarn's name plates use, so they no longer drift apart with the camera's angle), and
  `fInfoBarMaxDistance` / `bInfoBarRequireLineOfSight`, which hide a floating bar while its actor is out of range or
  sight (off by default). How Dovakarn's DLL is built: `DOVAKARN-BUILD.md`.
- Source: `swf/Widgets/TrueHUD_InfoBarBase.as` (`calculateLiftY`, `updateLiftY`, called from `moveResources`) and
  `swf/Widgets/TrueHUD_InfoBar.as` (switches it on). How the shipped SWF is built: `swf/ffdec/BUILD.md`.

---
## Requirements
* [CMake](https://cmake.org/)
	* Add this to your `PATH`
* [The Elder Scrolls V: Skyrim Special Edition](https://store.steampowered.com/app/489830)
	* Add the environment variable `CompiledPluginsPath` to point to the folder where you want the .dll to be copied after building
* [Vcpkg](https://github.com/microsoft/vcpkg)
	* Add the environment variable `VCPKG_ROOT` with the value as the path to the folder containing vcpkg
* [Visual Studio Community 2022](https://visualstudio.microsoft.com/)
	* Desktop development with C++
* [CommonLibSSE-NG](https://github.com/alandtse/CommonLibVR/tree/ng)
	* Add the environment variable `CommonLibSSEPath_NG` with the value as the path to the folder containing CommonLibSSE-NG

## User Requirements
* [Address Library for SKSE](https://www.nexusmods.com/skyrimspecialedition/mods/32444)

## Building
```
git clone https://github.com/ersh1/TrueHUD/
cd TrueHUD
git submodule init
git submodule update

cmake --preset vs2022-windows
cmake --build build --config Release
```
