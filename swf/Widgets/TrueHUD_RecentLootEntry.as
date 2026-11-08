import flash.geom.ColorTransform;
import flash.geom.Transform;

import com.greensock.TimelineLite;
import com.greensock.TweenLite;
import com.greensock.easing.*;

class Widgets.TrueHUD_RecentLootEntry extends MovieClip
{
	public var ItemText: TextField;
	public var ItemIcon: MovieClip;

	private var iconLoader: MovieClipLoader;
	private var iconSource: String = "skyui/icons_item_psychosteve.swf";

	var showHideTimeline: TimelineLite;
	var positionTween: TweenLite;

	var fRecentLootMessageDuration: Number;

	var animDuration = 0.25;

	var bIconsLoaded = false;
	var bFresh = true;
	var bReadyToRemove = false;

	var iconLabel: String;
	var iconColor: Number;

	public var itemName: String;
	public var itemCount: Number;

	// Dovakarn: the entry in the look of Dovakarn's own HUD compass (the workspace's local-tools/dovui hudmenu, HudCompass).
	// TrueHUD's pill and its white half-outline are hidden. Each line stands on a night band (#0A0E13, 0 to 62% over the RUN
	// before the words, 62% to the icon's end, then out to nothing over END) between two gold hairlines (#9C8757 to #D9B25F,
	// 0 to 80% at the icon and out again), the item's name in Sovngarde Light, the compass font's regular weight (Chris 8/11/2026: "unbold would look nicer"; embedded in TrueHUD_Widgets.swf as "Dov Sovngarde Light", swf/ffdec/BUILD.md step 5), in our UI's off-white
	// name and count in our UI's off-white #F0EEE7 (the kit's ink, as the HUD's arrow count; Chris 8/11: "Put them back to the off
	// white please that our UI uses. It contrasts well"), with the heavy drop shadow of Dovakarn's HUD words. Sizes below. The
	// icon stands on a soft night disc: a plain icon (white, or a grey or metal shade under PLAIN_SATURATION_PERCENT
	// saturation) and gold coins in that off-white, soul gems and the
	// other coloured kinds keep SkyUI's colour.
	static var DOVAKARN_ICON_COLOR: Number = 0xF0EEE7;
	static var PLAIN_ICON_COLOR: Number = 0xFFFFFF;
	static var PLAIN_SATURATION_PERCENT: Number = 25;
	static var FONT: String = "Dov Sovngarde Light";
	static var NIGHT: Number = 0x0A0E13;
	static var GOLD: Number = 0xD9B25F;
	static var INK: Number = 0xF0EEE7;
	static var GOLD_BORDER: Number = 0x9C8757;
	static var COIN_LABEL: String = "misc_gold";
	// Sizes are units of Dovakarn's HUD (local-tools/dovui hudmenu: 1.44 px at 1440p at UI Scale 100%; the arrow count is Light
	// 22), drawn at dovLootScale: the TrueHUD units one of them takes, which the client writes into TrueHUD's movie
	// (_root.dovLootScale, skymp5-client lootScaleService.ts: DovLogic.uiStageScale for the screen and the player's UI Scale over
	// TrueHUD's showAll stage). SCALE_DEFAULT when no client has written it: a screen 1000 px tall or more at 100%.
	static var SIZE: Number = 22;
	static var LEAST_SIZE: Number = 21;
	static var SPACING: Number = 0.3;
	static var MOST: Number = 420;
	static var BAND_H: Number = 30;
	static var RUN: Number = 80;
	static var END: Number = 22;
	static var SCALE_DEFAULT: Number = 0.72;
	static var SHADE: Number = 62;
	static var LINE: Number = 80;
	static var TEXT_RIGHT: Number = -42;
	static var ICON: Number = 27;
	static var ICON_LEFT: Number = -34;
	static var DISC: Number = 22;
	static var DISC_SHADE: Number = 70;

	var dovGround: MovieClip;
	var dovName: TextField;

	static function isPlainIcon(a_color: Number, a_label: String): Boolean
	{
		if (a_label != undefined && String(a_label).indexOf("soulgem") != -1)
		{
			return false;
		}
		var r: Number = (a_color >> 16) & 0xFF;
		var g: Number = (a_color >> 8) & 0xFF;
		var b: Number = a_color & 0xFF;
		var most: Number = Math.max(r, Math.max(g, b));
		var least: Number = Math.min(r, Math.min(g, b));
		if (most == 0)
		{
			return true;
		}
		return (most - least) * 100 < most * PLAIN_SATURATION_PERCENT;
	}

	static function iconTint(a_color: Number, a_label: String): Number
	{
		if (a_label == COIN_LABEL)
		{
			return INK;
		}
		return isPlainIcon(a_color, a_label) ? DOVAKARN_ICON_COLOR : a_color;
	}

	public function TrueHUD_RecentLootEntry()
	{
		// constructor code
		this.stop();

		if (this._url.indexOf("exported") != -1 || this._url.indexOf("Exported") != -1)
		{
			this.iconSource = "../" + this.iconSource
		}

		dovakarnStyle();
		applyScale(scaleNow());

		var iconLoader = new MovieClipLoader();
		iconLoader.addListener(this);
		iconLoader.loadClip(this.iconSource, ItemIcon);
		showHideTimeline = new TimelineLite({paused:true});
	}

	// TrueHUD's pill (the unnamed clip at the timeline's depth 1) and its text field are hidden; ours are drawn in their place
	private function dovakarnStyle(): Void
	{
		var pill: MovieClip = this.getInstanceAtDepth(-16383);
		if (pill != undefined && pill != ItemIcon)
		{
			pill._visible = false;
		}
		else
		{
			for (var key: String in this)
			{
				var child = this[key];
				if (typeof child == "movieclip" && child != ItemIcon && child._name.indexOf("instance") == 0)
				{
					child._visible = false;
				}
			}
		}
		ItemText._visible = false;
		dovGround = this.createEmptyMovieClip("dovGround", 10);
		var w: Number = MOST + 8;
		this.createTextField("dovName", 20, TEXT_RIGHT - w + 2, -10, w, Math.ceil(SIZE * 0.95) + 6);
		dovName.embedFonts = true;
		dovName.html = false;
		dovName.selectable = false;
		dovName.multiline = false;
		dovName.wordWrap = false;
		dovName.border = false;
		dovName.background = false;
		dovName.filters = [new flash.filters.DropShadowFilter(2, 90, 0, 1, 7, 7, 3.2, 2)];
		ItemIcon.swapDepths(30);
		ItemIcon._x = ICON_LEFT;
		ItemIcon._y = -ICON / 2;
	}

	static function scaleNow(): Number
	{
		var s: Number = Number(_root.dovLootScale);
		if (isNaN(s) || s < 0.2 || s > 4)
		{
			return SCALE_DEFAULT;
		}
		return s;
	}

	public function applyScale(a_scale: Number): Void
	{
		this._xscale = a_scale * 100;
		this._yscale = a_scale * 100;
	}

	private function format(a_size: Number, a_color: Number): TextFormat
	{
		var f: TextFormat = new TextFormat();
		f.font = FONT;
		f.size = a_size;
		f.color = a_color;
		f.align = "right";
		f.letterSpacing = SPACING;
		f.kerning = true;
		f.leading = 0;
		return f;
	}

	private function onLoadInit(a_icon: MovieClip): Void
	{
		bIconsLoaded = true;

		updateIcon();

		ItemIcon._width = ICON;
		ItemIcon._height = ICON;
		ItemIcon._x = ICON_LEFT;
		ItemIcon._y = -ICON / 2;
		ItemIcon._visible = true;
	}

	public function init()
	{
		showHideTimeline.clear();
		showHideTimeline.set(this, {_alpha:0, _x:50}, 0);
		showHideTimeline.to(this, animDuration, {_alpha:100, _x:0}, animDuration);
		showHideTimeline.to(this, animDuration, {_alpha:0}, fRecentLootMessageDuration);
		showHideTimeline.set(this, {bReadyToRemove:true});
		showHideTimeline.eventCallback("onStart", setReadyToRemove, [false], this);
		showHideTimeline.eventCallback("onComplete", setReadyToRemove, [true], this);
	}

	public function cleanUp()
	{
		showHideTimeline.eventCallback("onStart", null);
		showHideTimeline.eventCallback("onComplete", null);
		showHideTimeline.clear();
		showHideTimeline.kill();
		showHideTimeline = null;

		positionTween.kill();
		positionTween = null;
	}

	public function loadConfig(a_fRecentLootMessageDuration: Number)
	{
		fRecentLootMessageDuration = a_fRecentLootMessageDuration;

		init();
	}

	public function updateIcon()
	{
		ItemIcon.gotoAndStop(iconLabel);

		var colorTransform = new ColorTransform();
		var transform = new Transform(MovieClip(ItemIcon));

		colorTransform.rgb = iconTint(iconColor, iconLabel);
		transform.colorTransform = colorTransform;
	}

	public function addMessage(a_itemName: String, a_itemCount: Number, a_iconLabel: String, a_iconColor: Number, a_bInstant: Boolean)
	{
		itemName = a_itemName;
		itemCount = a_itemCount;

		updateName();

		iconLabel = a_iconLabel;
		iconColor = a_iconColor;

		if (bIconsLoaded) {
			updateIcon();
		}

		setReadyToRemove(false);
		if (a_bInstant)
		{
			showHideTimeline.play(animDuration);
		}
		else
		{
			showHideTimeline.restart();
		}

		bFresh = true;
	}

	private function showWords(a_name: String, a_count: String, a_size: Number): Number
	{
		var words: String = a_name + a_count;
		dovName.text = words;
		dovName.setTextFormat(format(a_size, INK));
		if (a_count.length > 0)
		{
			dovName.setTextFormat(a_name.length, words.length, format(a_size, INK));
		}
		return dovName.textWidth;
	}

	public function updateName()
	{
		var name: String = itemName != undefined ? String(itemName) : "";
		var count: String = itemCount > 1 ? " (" + itemCount.toString() + ")" : "";
		var size: Number = SIZE;
		var width: Number = showWords(name, count, size);
		while (width > MOST && size > LEAST_SIZE)
		{
			size--;
			width = showWords(name, count, size);
		}
		var cut: String = name;
		while (width > MOST && cut.length > 1)
		{
			cut = cut.substr(0, cut.length - 1);
			while (cut.length > 1 && cut.charAt(cut.length - 1) == " ")
			{
				cut = cut.substr(0, cut.length - 1);
			}
			width = showWords(cut + "...", count, size);
		}
		dovName._y = Math.round(-size * 0.95 / 2) - 2;
		layoutGround(width);
	}

	// The compass's band and hairlines behind the words, running out to nothing on the left; a soft night disc behind the icon
	private function layoutGround(a_textWidth: Number): Void
	{
		var g: MovieClip = dovGround;
		g.clear();
		var top: Number = -BAND_H / 2;
		var left: Number = TEXT_RIGHT - a_textWidth - RUN;
		// Out to nothing past the icon too, as the compass's band at both its ends: the list stands in from the screen's edge
		var w: Number = END - left;
		var full: Number = Math.round(255 * RUN / w);
		var iconEnd: Number = Math.round(255 * (ICON_LEFT + ICON - left) / w);
		var peak: Number = Math.round(255 * (ICON_LEFT + ICON / 2 - left) / w);
		grad(g, left, top, w, BAND_H, [NIGHT, NIGHT, NIGHT, NIGHT], [0, SHADE, SHADE, 0], [0, full, iconEnd, 255]);
		grad(g, left, top, w, 1, [GOLD_BORDER, GOLD, GOLD_BORDER], [0, LINE, 0], [0, peak, 255]);
		grad(g, left, top + BAND_H - 1, w, 1, [GOLD_BORDER, GOLD, GOLD_BORDER], [0, LINE, 0], [0, peak, 255]);
		var cx: Number = ICON_LEFT + ICON / 2;
		g.beginGradientFill("radial", [NIGHT, NIGHT], [DISC_SHADE, 0], [0, 255], {matrixType: "box", x: cx - DISC, y: -DISC, w: DISC * 2, h: DISC * 2, r: 0});
		g.moveTo(cx - DISC, -DISC);
		g.lineTo(cx + DISC, -DISC);
		g.lineTo(cx + DISC, DISC);
		g.lineTo(cx - DISC, DISC);
		g.lineTo(cx - DISC, -DISC);
		g.endFill();
	}

	private function grad(a_mc: MovieClip, a_x: Number, a_y: Number, a_w: Number, a_h: Number, a_colours: Array, a_alphas: Array, a_ratios: Array): Void
	{
		if (a_w <= 0 || a_h <= 0)
		{
			return;
		}
		a_mc.beginGradientFill("linear", a_colours, a_alphas, a_ratios, {matrixType: "box", x: a_x, y: a_y, w: a_w, h: a_h, r: 0});
		a_mc.moveTo(a_x, a_y);
		a_mc.lineTo(a_x + a_w, a_y);
		a_mc.lineTo(a_x + a_w, a_y + a_h);
		a_mc.lineTo(a_x, a_y + a_h);
		a_mc.lineTo(a_x, a_y);
		a_mc.endFill();
	}

	public function addCount(a_itemCount: Number)
	{
		itemCount = itemCount + a_itemCount;
		updateName();
	}

	public function setY(a_y: Number)
	{
		if (bFresh)
		{
			this._y = a_y;
			bFresh = false;
		}
		else
		{
			positionTween = TweenLite.to(this, animDuration, {_y:a_y, ease:Sine.easeIn});
		}
	}

	public function hideMessage()
	{
		if (showHideTimeline.time() < animDuration + fRecentLootMessageDuration)
		{
			showHideTimeline.play(fRecentLootMessageDuration);
		}
	}

	// Dovakarn: still shown (not yet fading out), and shown its full time again from now (the list's merge)
	public function isShowing() : Boolean
	{
		return !bReadyToRemove && showHideTimeline.time() < fRecentLootMessageDuration;
	}

	public function refresh()
	{
		showHideTimeline.play(animDuration * 2);
	}

	public function isJustAdded() : Boolean
	{
		return showHideTimeline.time() == 0;
	}

	public function isReadyToRemove() : Boolean
	{
		return bReadyToRemove;
	}

	public function setReadyToRemove(a_readyToRemove: Boolean)
	{
		bReadyToRemove = a_readyToRemove;
	}
}
