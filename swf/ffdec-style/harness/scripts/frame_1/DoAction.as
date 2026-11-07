// An offline stage for the Recent Loot list (swf/ffdec/BUILD.md step 5): loads a TrueHUD_Widgets.swf beside it (FlashVar
// "widgets", default TrueHUD_Widgets.swf), puts the list where TrueHUD does (the right edge, 85% down a 1280 x 720 stage) and
// adds six lines a tenth of a second apart: a soul gem, a Russian name, a long potion, a potion, arrows, gold. Each line stays
// a minute. The folder it runs in needs TrueHUD_Assets0-2.swf, gfxfontlib.swf and skyui/icons_item_psychosteve.swf
// FlashVar "scale": _root.dovLootScale, as the client writes it (TrueHUD units per unit of Dovakarn's HUD)
if (_root.scale != undefined) _root.dovLootScale = Number(_root.scale);
var file = _root.widgets != undefined ? String(_root.widgets) : "TrueHUD_Widgets.swf";
var holder = this.createEmptyMovieClip("holder", 1);
var loader = new MovieClipLoader();
var listener = new Object();
var feed = [
 ["Grand Soul Gem", 1, "soulgem_grandfull", 0xE3E0FF],
 ["Железный кинжал", 1, "weapon_dagger", 0xA4A5BF],
 ["Elixir of Extreme Health Regeneration of the Old Kings", 3, "potion_health", 0xDB2E73],
 ["Potion of Ultimate Healing", 2, "potion_health", 0xDB2E73],
 ["Iron Arrow", 58, "weapon_arrow", 0xA89E8C],
 ["Gold", 25, "misc_gold", 0xCCCC33]
];
listener.onLoadInit = function(t) {
  var list = holder.attachMovie("TrueHUD_RecentLootList", "list", 5);
  list._x = 1280;
  list._y = 612;
  list.loadConfig(10, 60, 100, 0);
  var i = 0;
  var frames = 0;
  var tick = holder.createEmptyMovieClip("tick", 9);
  tick.onEnterFrame = function() {
    frames++;
    if (frames % 6 == 0 && i < feed.length) {
      var f = feed[i];
      list.addMessage(f[0], f[1], f[2], f[3]);
      i++;
    }
    list.update();
  };
};
loader.addListener(listener);
loader.loadClip(file, holder);
