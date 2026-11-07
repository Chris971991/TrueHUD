# Building the patched TrueHUD_Widgets.swf

The changes are in the widget's ActionScript sources (`swf/Widgets/TrueHUD_InfoBarBase.as`, `swf/Widgets/TrueHUD_InfoBar.as`
on `dovakarn/1.1.9-lift-bars`; `swf/Widgets/TrueHUD_RecentLootEntry.as` on `dovakarn/1.1.9-loot-gold`). The `.fla` files
need Adobe Animate to publish, so the shipped SWF is built from the released one with the free JPEX Free Flash Decompiler
(FFDec, https://github.com/jindrapetrik/jpexs-decompiler) instead, in two steps:

1. Start from TrueHUD 1.1.9's own `Interface/TrueHUD_Widgets.swf` (the file in the Nexus release of this commit,
   `2c7232f` "Version 1.1.9"), sha256 `f77fd1c2b891ecff4006eb958a5821e8b2523670562fb9b89ad9cdeb150bcd26`.
2. **The info bar** (`dovakarn/1.1.9-lift-bars`): `scripts/__Packages/Widgets/TrueHUD_InfoBarBase.as` and
   `TrueHUD_InfoBar.as` in this folder are FFDec's decompiled 1.1.9 scripts with the same change as the sources made to
   them (FFDec's compiler takes its own decompiled form; it cannot parse the original sources' `import` lines). Compile
   them in (FFDec 26.3.0):

   ```
   java -jar ffdec-cli.jar -importScript TrueHUD_Widgets.swf TrueHUD_Widgets.lift.swf swf/ffdec
   ```

   The result has sha256 `3ab0f616515fbaef85dffda0aba8ef3ab1db0b470bce75a76d3f5180e0195ee2`. Decompiling it again gives
   these two scripts back (FFDec writes `switch` endings its own way); every other script and every shape is unchanged.
   Another FFDec version compiles the same scripts with other register numbers, so it gives the same behaviour with other
   bytes.
3. **Recent Loot in Dovakarn's gold** (`dovakarn/1.1.9-loot-gold`): `swf/ffdec-loot/scripts/__Packages/Widgets/TrueHUD_RecentLootEntry.as`
   is FFDec's decompiled 1.1.9 entry script with the source's change: the item's name and count in `#F2DFAE` (Dovakarn's
   `gold-ink`) instead of the text field's white, set after each `htmlText`, and an icon the plugin left white
   (`0xFFFFFF`, its default for a kind with no colour of its own) tinted `#D9B25F` (Dovakarn's `gold`). Icons with their
   own colour and the pill behind the entry are unchanged. Compile it into step 2's file, and only it, so the info bar's
   bytes stay as shipped (FFDec 26.2.0):

   ```
   java -jar ffdec-cli.jar -importScript TrueHUD_Widgets.lift.swf TrueHUD_Widgets.patched.swf swf/ffdec-loot
   ```

   The result used by Dovakarn has sha256 `36c6cc0a0ec56b301aaa19b8aeb0096736bc4f60937e4dbd2bf5c5345a018e3d`. Against
   step 2's file, decompiling shows only `TrueHUD_RecentLootEntry.as` changed, and an XML dump of both (`-swf2xml`)
   differs in that class's one `DoInitAction` tag and nothing else.
4. **Recent Loot: grey icons, the same item merged** (`dovakarn/1.1.9-loot-gold`, 8/11/2026):
   `swf/ffdec-pickup/scripts/__Packages/Widgets/` holds FFDec's decompiled `TrueHUD_RecentLootEntry.as` and
   `TrueHUD_RecentLootList.as` (from step 3's file) with the sources' changes: an icon is plain, and drawn in `#D9B25F`,
   when its colour is less than 25% saturated (white and SkyUI's grey and metal shades), soul gems keeping their violet;
   the same item arriving while its line still shows adds to that line, which moves to the top and shows its full time
   again. Compile them into step 3's file (FFDec 26.2.0):

   ```
   java -jar ffdec-cli.jar -importScript TrueHUD_Widgets.patched.swf TrueHUD_Widgets.pickup.swf swf/ffdec-pickup
   ```

   The result used by Dovakarn has sha256 `6bbcd4071a2a8244d5be6d251071b4c08334f2b063b02387a0dd85a9a7f6ff9f`.
   Decompiling it again and step 3's file shows only those two scripts changed.
5. **Recent Loot in the look of Dovakarn's HUD compass** (`dovakarn/1.1.9-loot-gold`, 8/11/2026):
   `swf/ffdec-style/scripts/__Packages/Widgets/` holds step 4's two scripts with the sources' changes: TrueHUD's pill and
   its white half-outline (the unnamed clip at the entry's timeline depth 1) and the `ItemText` field are hidden; each
   line is drawn on a night band (`#0A0E13`, 0 to 62%) between two gold hairlines (`#9C8757` to `#D9B25F`, 0 to 80%)
   running out to nothing on the left and again past the icon, the name in Sovngarde Light 22 (the regular weight of
   the compass's font) in `#F2DFAE` and its count in `#C4B07F` with a heavy drop shadow, a long name stepping down to 21
   and then cut with "...", the icon (27) on a soft night disc, gold coins in `#FFDF85`; rows 40 apart. Every size is a
   unit of Dovakarn's own HUD movie (1.44 px at 1440p at UI Scale 100%), drawn at `_root.dovLootScale` TrueHUD units each:
   Dovakarn's client writes it into TrueHUD's movie from the screen and the player's UI Scale (0.72 at 100% on a screen
   1000 px tall or more, the widget's default when nothing wrote it), and the list scales every line and its row spacing
   by it each frame it changes. Compile them into step 4's file (FFDec 26.2.1), then embed the font the new text field
   asks for:

   ```
   java -jar ffdec-cli.jar -importScript TrueHUD_Widgets.pickup.swf TrueHUD_Widgets.style-scripts.swf swf/ffdec-style
   node swf/ffdec-style/add-fonts.cjs TrueHUD_Widgets.style-scripts.swf hudmenu.swf TrueHUD_Widgets.style.swf "Dov Sovngarde Light"
   ```

   `add-fonts.cjs` (Node 18, no packages) copies the named DefineFont3 tag, its DefineFontAlignZones and DefineFontName,
   byte for byte, from a donor SWF into the next free character id, exports it under its name and puts it after
   SetBackgroundColor; nothing else changes. The donor is Dovakarn's HUD Menu movie, `Data/Interface/hudmenu.swf`
   (sha256 `47e28b662b6588e479cad12718ff9e1627323431810eb393208f80aa173e15b0`), whose compass and notes draw this family: Sovngarde
   Light (Copyright (c) 2016, mjorka, mjorka.net, SIL Open Font License 1.1) as "Dov Sovngarde Light", printable ASCII, Latin-1,
   the curly quotes and the Russian alphabet. A font has to be inside this movie: TrueHUD's movie cannot reach the fonts
   of another movie, and Skyrim's font library (`fontconfig.txt`, `gfxfontlib.swf`) holds only Skyrim's faces.

   The result used by Dovakarn has sha256 `59307b3c07b40c12621f1ccebd60b1b50a5c88cf53a5486385aeda541a90312a`; the same
   commands give the same bytes again. Decompiling it and step 4's file shows only those two scripts changed.

   `swf/ffdec-style/harness/scripts/frame_1/DoAction.as` is an offline stage for the list (compile it with
   `-importScript` into any one-frame AS2 SWF of 1280 x 720): it loads the widgets beside it (FlashVar `scale` sets `_root.dovLootScale`) and adds six lines, a soul
   gem, a Russian name, a long potion, a potion, arrows and gold. Dovakarn renders it in Ruffle (the workspace's dovui
   `tools/render.cjs`); Ruffle has no `textAutoSize`, so TrueHUD's own file cuts a long name there where the game
   shrinks it.
