class Widgets.TrueHUD_RecentLootEntry extends MovieClip
{
   var ItemIcon;
   var ItemText;
   var fRecentLootMessageDuration;
   var iconColor;
   var iconLabel;
   var itemCount;
   var itemName;
   var positionTween;
   var showHideTimeline;
   var iconSource = "skyui/icons_item_psychosteve.swf";
   var animDuration = 0.25;
   var bIconsLoaded = false;
   var bFresh = true;
   var bReadyToRemove = false;
   static var DOVAKARN_TEXT_COLOR = 15916974;
   static var DOVAKARN_ICON_COLOR = 14266975;
   static var PLAIN_ICON_COLOR = 16777215;
   static var PLAIN_SATURATION_PERCENT = 25;
   function TrueHUD_RecentLootEntry()
   {
      super();
      this.stop();
      if(this._url.indexOf("exported") != -1 || this._url.indexOf("Exported") != -1)
      {
         this.iconSource = "../" + this.iconSource;
      }
      var _loc3_ = new MovieClipLoader();
      _loc3_.addListener(this);
      _loc3_.loadClip(this.iconSource,this.ItemIcon);
      this.showHideTimeline = new com.greensock.TimelineLite({paused:true});
   }
   function onLoadInit(a_icon)
   {
      this.bIconsLoaded = true;
      this.updateIcon();
      this.ItemIcon._width = 24;
      this.ItemIcon._height = 24;
      this.ItemIcon._visible = true;
   }
   function init()
   {
      this.showHideTimeline.clear();
      this.showHideTimeline["set"](this,{_alpha:0,_x:50},0);
      this.showHideTimeline.to(this,this.animDuration,{_alpha:100,_x:0},this.animDuration);
      this.showHideTimeline.to(this,this.animDuration,{_alpha:0},this.fRecentLootMessageDuration);
      this.showHideTimeline["set"](this,{bReadyToRemove:true});
      this.showHideTimeline.eventCallback("onStart",this.setReadyToRemove,[false],this);
      this.showHideTimeline.eventCallback("onComplete",this.setReadyToRemove,[true],this);
   }
   function cleanUp()
   {
      this.showHideTimeline.eventCallback("onStart",null);
      this.showHideTimeline.eventCallback("onComplete",null);
      this.showHideTimeline.clear();
      this.showHideTimeline.kill();
      this.showHideTimeline = null;
      this.positionTween.kill();
      this.positionTween = null;
   }
   function loadConfig(a_fRecentLootMessageDuration)
   {
      this.fRecentLootMessageDuration = a_fRecentLootMessageDuration;
      this.init();
   }
   static function isPlainIcon(a_color, a_label)
   {
      if(a_label != undefined && String(a_label).indexOf("soulgem") != -1)
      {
         return false;
      }
      var _loc3_ = a_color >> 16 & 255;
      var _loc4_ = a_color >> 8 & 255;
      var _loc5_ = a_color & 255;
      var _loc1_ = Math.max(_loc3_,Math.max(_loc4_,_loc5_));
      var _loc2_ = Math.min(_loc3_,Math.min(_loc4_,_loc5_));
      if(_loc1_ == 0)
      {
         return true;
      }
      return (_loc1_ - _loc2_) * 100 < _loc1_ * Widgets.TrueHUD_RecentLootEntry.PLAIN_SATURATION_PERCENT;
   }
   function updateIcon()
   {
      this.ItemIcon.gotoAndStop(this.iconLabel);
      var _loc2_ = new flash.geom.ColorTransform();
      var _loc3_ = new flash.geom.Transform(MovieClip(this.ItemIcon));
      _loc2_.rgb = !Widgets.TrueHUD_RecentLootEntry.isPlainIcon(this.iconColor,this.iconLabel) ? this.iconColor : Widgets.TrueHUD_RecentLootEntry.DOVAKARN_ICON_COLOR;
      _loc3_.colorTransform = _loc2_;
   }
   function addMessage(a_itemName, a_itemCount, a_iconLabel, a_iconColor, a_bInstant)
   {
      this.itemName = a_itemName;
      this.itemCount = a_itemCount;
      this.updateName();
      this.iconLabel = a_iconLabel;
      this.iconColor = a_iconColor;
      if(this.bIconsLoaded)
      {
         this.updateIcon();
      }
      this.setReadyToRemove(false);
      if(a_bInstant)
      {
         this.showHideTimeline.play(this.animDuration);
      }
      else
      {
         this.showHideTimeline.restart();
      }
      this.bFresh = true;
   }
   function updateName()
   {
      var _loc2_ = this.itemName;
      if(this.itemCount > 1)
      {
         _loc2_ = _loc2_ + " (" + this.itemCount.toString() + ")";
      }
      this.ItemText.html = true;
      this.ItemText.textAutoSize = "shrink";
      this.ItemText.htmlText = _loc2_;
      this.ItemText.textColor = Widgets.TrueHUD_RecentLootEntry.DOVAKARN_TEXT_COLOR;
   }
   function addCount(a_itemCount)
   {
      this.itemCount += a_itemCount;
      this.updateName();
   }
   function setY(a_y)
   {
      if(this.bFresh)
      {
         this._y = a_y;
         this.bFresh = false;
      }
      else
      {
         this.positionTween = com.greensock.TweenLite.to(this,this.animDuration,{_y:a_y,ease:com.greensock.easing.Sine.easeIn});
      }
   }
   function hideMessage()
   {
      if(this.showHideTimeline.time() < this.animDuration + this.fRecentLootMessageDuration)
      {
         this.showHideTimeline.play(this.fRecentLootMessageDuration);
      }
   }
   function isShowing()
   {
      return !this.bReadyToRemove && this.showHideTimeline.time() < this.fRecentLootMessageDuration;
   }
   function refresh()
   {
      this.showHideTimeline.play(this.animDuration * 2);
   }
   function isJustAdded()
   {
      return this.showHideTimeline.time() == 0;
   }
   function isReadyToRemove()
   {
      return this.bReadyToRemove;
   }
   function setReadyToRemove(a_readyToRemove)
   {
      this.bReadyToRemove = a_readyToRemove;
   }
}
