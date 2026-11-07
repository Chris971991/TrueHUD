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

	// Dovakarn: the entry's words in Dovakarn's gold-ink (#F2DFAE) instead of the field's white, and a plain icon in
	// Dovakarn's gold (#D9B25F). Plain is white (0xFFFFFF, the plugin's default for a kind without a colour of its own) and
	// every grey or metal shade SkyUI's table gives (weapons 0xA4A5BF, ammo and firewood 0xA89E8C, heavy armour 0x6B7585,
	// ingots 0x828282): a colour less than PLAIN_SATURATION_PERCENT saturated. Soul gems keep SkyUI's pale violet, and
	// coloured kinds (potions, gold coins, gems, leather, clothes) keep theirs. The pill behind the entry is unchanged.
	static var DOVAKARN_TEXT_COLOR: Number = 0xF2DFAE;
	static var DOVAKARN_ICON_COLOR: Number = 0xD9B25F;
	static var PLAIN_ICON_COLOR: Number = 0xFFFFFF;
	static var PLAIN_SATURATION_PERCENT: Number = 25;

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

	public function TrueHUD_RecentLootEntry() 
	{
		// constructor code
		this.stop();

		if (this._url.indexOf("exported") != -1 || this._url.indexOf("Exported") != -1) 
		{
			this.iconSource = "../" + this.iconSource 
		}

		var iconLoader = new MovieClipLoader();
		iconLoader.addListener(this);
		iconLoader.loadClip(this.iconSource, ItemIcon);
		showHideTimeline = new TimelineLite({paused:true});
	}

	private function onLoadInit(a_icon: MovieClip): Void
	{
		bIconsLoaded = true;

		updateIcon();

		ItemIcon._width = 24;
		ItemIcon._height = 24;
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

		colorTransform.rgb = isPlainIcon(iconColor, iconLabel) ? DOVAKARN_ICON_COLOR : iconColor;
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

	public function updateName()
	{
		var name = itemName;
		if (itemCount > 1)
		{
			name = name + " (" + itemCount.toString() + ")";
		}
		ItemText.html = true;
		ItemText.textAutoSize = "shrink";
		ItemText.htmlText = name;
		// (after the text: setting htmlText starts again from the field's own white)
		ItemText.textColor = DOVAKARN_TEXT_COLOR;
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
