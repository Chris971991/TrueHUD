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
