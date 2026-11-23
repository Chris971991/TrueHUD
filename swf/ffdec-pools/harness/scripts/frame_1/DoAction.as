// Offline stage for TrueHUD's floating info bar (item 44, real bars only): loads a TrueHUD_Widgets.swf beside it (FlashVar
// "widgets"), makes one TrueHUD_InfoBar per case, feeds it updateData as the DLL does, and after the tweens settle reports each
// bar's resource state through ExternalInterface "dovTrace" (one line per case).
var file = _root.widgets != undefined ? String(_root.widgets) : "TrueHUD_Widgets.swf";
var holder = this.createEmptyMovieClip("holder", 1);
var loader = new MovieClipLoader();
var listener = new Object();
// name, targetType (0 target, 3 other), pools (undefined = an older DLL), magicka %, stamina %
var cases = [
 ["full-target-old-dll", 0, undefined, 1, 1],
 ["full-target-both", 0, 3, 1, 1],
 ["mudcrab-target", 0, 2, 1, 1],
 ["seeker-target", 0, 1, 0.4, 1],
 ["none-target", 0, 0, 1, 1],
 ["other-full", 3, 2, 1, 1],
 ["other-stamina-low", 3, 2, 1, 0.5],
 ["other-magicka-low-no-pool", 3, 2, 0.5, 1],
 ["other-magicka-low-both", 3, 3, 0.5, 1],
 ["other-magicka-only-low", 3, 1, 0.5, 1],
 ["pools-change-both-to-stamina", 0, 3, 1, 1],
 ["killed-stamina", 0, 2, 1, 1]
];
var bars = [];
function cfg(w) {
  w.loadConfig(0, 0, true, false, 0, 4, 0, 2, 1, 1, 1, 0, 0, 0, 0, true, 2, 0.75, 2, 100, 100, 70, 100, 70,
    0xDF2020, 0xFFFFFF, 0x000000, 0x000000, 0xFFFFFF,
    0x284BD7, 0xFFFFFF, 0x000000, 0x000000, 0xFFFFFF,
    0x007E00, 0xFFFFFF, 0x000000, 0x000000, 0xFFFFFF,
    0xFFFFFF, 0xFFFFFF, 0x000000, 0x000000, 0xFFFFFF);
}
function feed(w, c, state) {
  var m = c[3] * 100;
  var s = c[4] * 100;
  w.updateData(c[1], 0, 0, state, "Case", 5, 0xFFFFFF, 0x000000, 1, 100, 100, 1, 100, m, c[3], 100, s, c[4], c[2]);
}
listener.onLoadInit = function(t) {
  for (var i = 0; i < cases.length; i++) {
    var w = holder.attachMovie("TrueHUD_InfoBar", "bar" + i, 10 + i);
    w._x = 120 + (i % 4) * 300;
    w._y = 120 + Math.floor(i / 4) * 200;
    cfg(w);
    bars.push(w);
  }
  var frames = 0;
  var tick = holder.createEmptyMovieClip("tick", 9999);
  tick.onEnterFrame = function() {
    frames++;
    if (frames < 3) return;
    for (var i = 0; i < cases.length; i++) {
      var c = cases[i];
      var w = bars[i];
      if (c[0] == "pools-change-both-to-stamina" && frames > 40) {
        c[2] = 2;
      }
      feed(w, c, (c[0] == "killed-stamina" && frames > 40) ? 4 : 0);
    }
    if (frames == 90) {
      for (var j = 0; j < cases.length; j++) {
        var b = bars[j];
        var col = new Color(b.Bars.Resources.StaminaBar.Bar.Color);
        flash.external.ExternalInterface.call("dovTrace", cases[j][0] + "|shown=" + b.uDisplayedResources + "|lowerMagicka=" + b.bLowerIsMagicka +
          "|barsY=" + Math.round(b.Bars._y * 100) / 100 + "|resY=" + Math.round(b.Bars.Resources._y * 100) / 100 +
          "|lowerPct=" + b.Bars.Resources.StaminaBar.percent + "|lowerColor=" + col.getRGB().toString(16));
      }
      flash.external.ExternalInterface.call("dovTrace", "done");
    }
  };
};
loader.addListener(listener);
loader.loadClip(file, holder);

