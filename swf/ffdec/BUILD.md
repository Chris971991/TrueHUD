# Building the patched TrueHUD_Widgets.swf

The change on this branch is in the widget's ActionScript sources (`swf/Widgets/TrueHUD_InfoBarBase.as`,
`swf/Widgets/TrueHUD_InfoBar.as`). The `.fla` files need Adobe Animate to publish, so the shipped SWF is built from the
released one with the free JPEX Free Flash Decompiler (FFDec, https://github.com/jindrapetrik/jpexs-decompiler) instead:

1. Start from TrueHUD 1.1.9's own `Interface/TrueHUD_Widgets.swf` (the file in the Nexus release of this commit,
   `2c7232f` "Version 1.1.9"), sha256 `f77fd1c2b891ecff4006eb958a5821e8b2523670562fb9b89ad9cdeb150bcd26`.
2. `scripts/__Packages/Widgets/TrueHUD_InfoBarBase.as` and `TrueHUD_InfoBar.as` in this folder are FFDec's decompiled
   1.1.9 scripts with the same change as the sources made to them (FFDec's compiler takes its own decompiled form; it
   cannot parse the original sources' `import` lines).
3. Compile them in (FFDec 26.3.0):

   ```
   java -jar ffdec-cli.jar -importScript TrueHUD_Widgets.swf TrueHUD_Widgets.patched.swf swf/ffdec
   ```

   The result used by Dovakarn has sha256 `3ab0f616515fbaef85dffda0aba8ef3ab1db0b470bce75a76d3f5180e0195ee2`.
   Decompiling it again gives these two scripts back (FFDec writes `switch` endings its own way); every other script
   and every shape is unchanged.
