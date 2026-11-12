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

## Recent Loot (branch `dovakarn/1.1.9-loot-gold`, 8/11/2026)

Built the same way, from this branch (`src/HUDHandler.cpp`, `src/Papyrus.cpp`):

- **`DovakarnLoot.Quiet(float afSeconds)`**, a global Papyrus native (`scripts/source/DovakarnLoot.psc`, compiled to
  `Scripts/DovakarnLoot.pex`, which must ship with the DLL): no Recent Loot line is made for that many seconds (0 ends
  it). Dovakarn's multiplayer client calls it while it puts the server's saved inventory back into the player's (the login,
  a load, a character switch, a correcting pass), so the list shows only real arrivals, not the whole pack.
- **Container, barter and gift menus:** with `bRecentLootHideInInventoryMenus` on, what the player gains while one of
  them is open is held (the same item added up) and shown when it closes, instead of never.
- The item's name is copied into the HUD task (it was a view of a reference's display name, read a frame later).

Dovakarn's build: sha256 `aab6a799c6d055167a225299d84f8a2565178fee2aa63dc5048c4f4e21724c8e` (CommonLibSSE-NG `cab9f743f`,
`-DTRUEHUD_DOVAKARN_DEFAULTS=ON`, as above). It pairs with `swf/ffdec/BUILD.md` step 4's `TrueHUD_Widgets.swf`.

## Health bars for anyone in a fight with the player (branch `dovakarn/1.1.9-health-bars`, 11/11/2026)

**Why.** TrueHUD adds a floating bar on a hit only when the hit actor `IsInCombat()`, and takes a bar away the moment its
actor is not. An enemy the game does not count as in combat (a still or unaware one, another player's copy, an NPC another
game hosts) got no bar however often it was hit: proven in game on 11/11/2026, 12 Flames hits on a still hostile wolf,
health 100% to 59%, no bar. From `dovakarn/1.1.9-loot-gold`; `src/HUDHandler.cpp`, `src/Scaleform/TrueHUDMenu.cpp`,
`src/Widgets/InfoBarBase.cpp`, `src/Widgets/ActorInfoBar.cpp`. Boss bars are untouched.

- **A fight with the player.** A hit event whose cause or target is the player itself (not a teammate) asks for the other
  actor's bar at once and marks it as in a fight (`HUDHandler::NoteActorFight`, `InfoBarBase::NoteFight`): for
  **`fInfoBarFightKeepTime`** seconds after the last such hit the bar stays whether or not the game counts the actor as in
  combat, and a combat end does not take it (`RemoveActorInfoBarOnCombatEnd`). A bar that was fading out is called back
  (one that was hidden when it began to leave, or has finished fading, is replaced by a fresh one). A dead actor's bar
  leaves as before. Whether hostiles or others show bars at all is still `uInfoBarDisplayHostiles` /
  `uInfoBarDisplayOthers` (0 = never). A keep time of 0 turns the whole rule off (TrueHUD's own behaviour). The time runs
  down by at most a quarter of a second a frame, so a stall (a loading screen) does not use it up.
- **Damage over time.** A burn or a poison raises a hit event when it is put on and none for its ticks. While the keep time
  runs, health falling to a new low (by 0.5 or more) counts as a hit landing, so the bar stays while the actor keeps losing
  health and for the keep time after.
- **`fInfoBarFightMaxDistance`**: an actor inside that keep time shows out to this range instead of `fInfoBarMaxDistance`
  (only when larger, and only while `fInfoBarMaxDistance` is on). Line of sight is still needed.
- **An attacker before its first hit** is TrueHUD's own `uInfoBarDisplayHostiles = 2` ("on combat start": the combat event
  with the player as its target adds the bar; 1 waits for a hit). Dovakarn serves 2 in its settings file.
- **A hidden bar's state runs on.** A bar hidden for range or sight used to stop being looked at, so one TrueHUD no longer
  wanted waited hidden and flashed up to fade out when its actor next came into range and sight. It is now treated as a
  bar off screen is: hidden in the movie too, removed unseen when it is no longer wanted, and it fades in (0.25 s) when it
  is back. A bar that is already leaving stays as it was, shown or hidden, until it is gone.
- **No 3D, no bar.** An actor with no 3D loaded has no point to draw at (TrueHUD used the world's origin): not drawn.
- **No menu.** The hit and combat handlers return when TrueHUD's menu is not there (they read through it).
- **The task queue** is taken under its lock before the tasks run (`HUDHandler::Process`); it was read and popped unlocked.

Defaults: 5 seconds and 3000 units with `-DTRUEHUD_DOVAKARN_DEFAULTS=ON`, 0 and 0 (off) without. Both can be set in
`[ActorInfoBars]` of a settings file.

**Threads.** The game's hit and combat events may come on any thread. As before they only read the two actors and queue a
HUD task under `HUDHandler::_lock`. Everything new (`_fightTimeLeft`, `_fightLowHealth`, `_bHiddenByRangeOrSight`) lives in
the bar's widget and is touched only on the thread that runs the menu (`TrueHUDMenu::AdvanceMovie`: the HUD tasks, then
each bar's `Update`).

### Two builds from one source

- **The build players get**: as "Build used by Dovakarn" above (`build-mt`). sha256
  `30d0a0c7ceebc2d58c6ad1cac76aeee4fa413b5a3fc752650858572c127bbb58`. It holds none of the dev build's code or strings
  (checked: no `dovBars`, `bInfoBarLog` or bar log text in the file, as ASCII or UTF-16).
- **The dev build**: the same command with **`-DTRUEHUD_DOVAKARN_DEV=ON`** added, in its own folder (`-B build-mt-dev`).
  It defines `DOVAKARN_DEV`, which the sources put the read-back and the bar log behind. sha256
  `8674cc00c31c197e80a725c26606027db7f539fffe65b196ecb6546ef37a1a71`. Never served: Dovakarn's dev tool puts it in the
  workshop game for a test session and puts the served one back.

Neither build has run in a game yet (built 11/11/2026 while in-game testing was on hold). Before serving: the load check in
Dovakarn's `docs/systems/nameplates.md` ("TrueHUD.dll: building it and proving it loads") and the readings listed there
under "Health bars in a fight".

### The bar read-back and the bar log (dev build only)

For finding out why a floating bar is missing without a picture.

- **`_root.dovBars`** in TrueHUD's menu movie (SkyrimPlatform: `Ui.getString("TrueHUD", "_root.dovBars")`), written only when
  it changes (`TrueHUDMenu::UpdateReadBack`):
  `m<menu mode: 0 hidden, 1 partial, 2 shown>,t<target's form id>,s<soft target's form id>,c<1: another plugin sets the targets>`
  then for each bar
  `|<actor's form id>:<a floating, b boss>:<widget state 0-5>:<target type 0-3>:<1 drawn, 0 not>:<why not>:<health %>:<fight>`.
  Widget state: 0 active, 1 hiding, 2 hidden, 3 leaving after a kill, 4 leaving, 5 removed. Target type: 0 target, 1 enemy,
  2 teammate, 3 other. Why not, the first that holds: `m` the whole menu is hidden, `r` out of range, `s` out of sight, `o` off
  screen, `h` its state is not active, `a` faded out, `-` nothing. Fight: 1 while the keep time after a hit between the actor
  and the player runs, 0 otherwise (new on this branch, added at the end). No bars: the head alone (`m2,t0,s0,c1`). An empty
  string: the DLL in the game is not the dev build.
- **`bInfoBarLog = 1`** in `[ActorInfoBars]` of a settings file (off by default): TrueHUD.log gets a line for every hit and
  combat event that involves the player or a teammate (who, with what, hostile, in combat, distance, has a bar), every
  target and soft target change, every bar asked for, added, removed or gone, every fight noted and every combat end, and
  each bar's read-back line (with `fight 0` or `fight 1`) whenever anything but its health changes.

The first diagnostic build (local branch `dovakarn/1.1.9-bar-readback`, `e1a93cd`, sha256 `ff849f82...`, no fix in it) was
loaded and read in the workshop game on 11/11/2026: that is where the proof above comes from.

## The server's fight feed and any new low (branch `dovakarn/1.1.9-fight-feed`, 12/11/2026)

From `dovakarn/1.1.9-health-bars`, built the same two ways (`build-mt` served, `build-mt-dev` with `-DTRUEHUD_DOVAKARN_DEV=ON`):

- **`DovakarnBars.Fight(Actor akActor)`**, a global Papyrus native (`scripts/source/DovakarnBars.psc`, compiled to
  `Scripts/DovakarnBars.pex`, which must ship with the DLL; `src/Papyrus.cpp`): the game server's word that akActor is in a
  fight with the player that this game raised no hit event for. Dovakarn's client calls it for another player's hit on the
  player (a copy's spell or swing never hits in this game), the player's heal on someone (the game's own gate refuses the
  caster's effect on another actor; the server lands it), and another player's hit on an NPC near the player. It adds or
  keeps the bar for `fInfoBarFightKeepTime` as a hit between the player and akActor does (`HUDHandler::NoteActorFight`),
  for the kinds the settings show at all (hostiles, teammates, others).
- **Damage over time counts every new low** (`InfoBarBase::UpdateInfo`): the keep time restarted only on a fall of half a
  point below the last low, so a weak dose's tail never counted (a Potent Poison's 1.5 points over 5 s on a 22-health wolf:
  the fight ended 3.46 s after the dose's last fall). Now a hundredth of a point (float noise only) is enough; a rise and a
  fall back to the old low still counts nothing.
- `DovakarnBars.pex` was compiled with the Creation Kit's PapyrusCompiler.exe against stubs of Form, ObjectReference and
  Actor (the workshop has no Package.psc; the script names only the Actor type): sha256
  `85df1298f5b8f085e93ab581861ede38f87b349a2195c24c93837dbf9b6fca5f`.

Dovakarn's builds: served sha256 `ede63e383f341c862b907202ffa60d2b21476957d7e0e9278bfe80b38895f357`, dev
`08e27355641f0cf44cb078d30ef786aa7ccef1be75b8fea96bb4852cc39161b3` (CommonLibSSE-NG `cab9f743f`,
`-DTRUEHUD_DOVAKARN_DEFAULTS=ON`; environment `CompiledPluginsPath`, `CommonLibSSEPath_NG`, `VCPKG_ROOT`, Visual Studio
Community 2026's CMake).
