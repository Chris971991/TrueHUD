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
   var dovGround;
   var dovName;
   var iconSource = "skyui/icons_item_psychosteve.swf";
   var animDuration = 0.25;
   var bIconsLoaded = false;
   var bFresh = true;
   var bReadyToRemove = false;
   static var DOVAKARN_ICON_COLOR = 14266975;
   static var PLAIN_ICON_COLOR = 16777215;
   static var PLAIN_SATURATION_PERCENT = 25;
   static var FONT = "Dov Sovngarde Light";
   static var NIGHT = 658963;
   static var GOLD = 14266975;
   static var GOLD_INK = 15916974;
   static var GOLD_DIM = 12890239;
   static var GOLD_BORDER = 10258263;
   static var GOLD_BRIGHT = 16768901;
   static var COIN_LABEL = "misc_gold";
   static var SIZE = 22;
   static var LEAST_SIZE = 21;
   static var SPACING = 0.3;
   static var MOST = 420;
   static var BAND_H = 30;
   static var RUN = 80;
   static var END = 22;
   static var SCALE_DEFAULT = 0.72;
   static var SHADE = 62;
   static var LINE = 80;
   static var TEXT_RIGHT = -42;
   static var ICON = 27;
   static var ICON_LEFT = -34;
   static var DISC = 22;
   static var DISC_SHADE = 70;
   function TrueHUD_RecentLootEntry()
   {
      super();
      this.stop();
      if(this._url.indexOf("exported") != -1 || this._url.indexOf("Exported") != -1)
      {
         this.iconSource = "../" + this.iconSource;
      }
      this.dovakarnStyle();
      this.applyScale(Widgets.TrueHUD_RecentLootEntry.scaleNow());
      var _loc3_ = new MovieClipLoader();
      _loc3_.addListener(this);
      _loc3_.loadClip(this.iconSource,this.ItemIcon);
      this.showHideTimeline = new com.greensock.TimelineLite({paused:true});
   }
   function dovakarnStyle()
   {
      var _loc4_ = this.getInstanceAtDepth(-16383);
      if(_loc4_ != undefined && _loc4_ != this.ItemIcon)
      {
         _loc4_._visible = false;
      }
      else
      {
         for(var _loc5_ in this)
         {
            var _loc3_ = this[_loc5_];
            if(typeof _loc3_ == "movieclip" && _loc3_ != this.ItemIcon && _loc3_._name.indexOf("instance") == 0)
            {
               _loc3_._visible = false;
            }
         }
      }
      this.ItemText._visible = false;
      this.dovGround = this.createEmptyMovieClip("dovGround",10);
      var _loc2_ = Widgets.TrueHUD_RecentLootEntry.MOST + 8;
      var _loc6_ = Math.ceil(Widgets.TrueHUD_RecentLootEntry.SIZE * 0.95) + 6;
      this.createTextField("dovName",20,Widgets.TrueHUD_RecentLootEntry.TEXT_RIGHT - _loc2_ + 2,-10,_loc2_,_loc6_);
      this.dovName.embedFonts = true;
      this.dovName.html = false;
      this.dovName.selectable = false;
      this.dovName.multiline = false;
      this.dovName.wordWrap = false;
      this.dovName.border = false;
      this.dovName.background = false;
      this.dovName.filters = [new flash.filters.DropShadowFilter(2,90,0,1,7,7,3.2,2)];
      this.ItemIcon.swapDepths(30);
      this.ItemIcon._x = Widgets.TrueHUD_RecentLootEntry.ICON_LEFT;
      this.ItemIcon._y = (- Widgets.TrueHUD_RecentLootEntry.ICON) / 2;
   }
   static function scaleNow()
   {
      var _loc1_ = Number(_root.dovLootScale);
      if(isNaN(_loc1_) || _loc1_ < 0.2 || _loc1_ > 4)
      {
         return Widgets.TrueHUD_RecentLootEntry.SCALE_DEFAULT;
      }
      return _loc1_;
   }
   function applyScale(a_scale)
   {
      this._xscale = a_scale * 100;
      this._yscale = a_scale * 100;
   }
   function format(a_size, a_color)
   {
      var _loc1_ = new TextFormat();
      _loc1_.font = Widgets.TrueHUD_RecentLootEntry.FONT;
      _loc1_.size = a_size;
      _loc1_.color = a_color;
      _loc1_.align = "right";
      _loc1_.letterSpacing = Widgets.TrueHUD_RecentLootEntry.SPACING;
      _loc1_.kerning = true;
      _loc1_.leading = 0;
      return _loc1_;
   }
   function onLoadInit(a_icon)
   {
      this.bIconsLoaded = true;
      this.updateIcon();
      this.ItemIcon._width = Widgets.TrueHUD_RecentLootEntry.ICON;
      this.ItemIcon._height = Widgets.TrueHUD_RecentLootEntry.ICON;
      this.ItemIcon._x = Widgets.TrueHUD_RecentLootEntry.ICON_LEFT;
      this.ItemIcon._y = (- Widgets.TrueHUD_RecentLootEntry.ICON) / 2;
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
   static function iconTint(a_color, a_label)
   {
      if(a_label == Widgets.TrueHUD_RecentLootEntry.COIN_LABEL)
      {
         return Widgets.TrueHUD_RecentLootEntry.GOLD_BRIGHT;
      }
      return !Widgets.TrueHUD_RecentLootEntry.isPlainIcon(a_color,a_label) ? a_color : Widgets.TrueHUD_RecentLootEntry.DOVAKARN_ICON_COLOR;
   }
   function updateIcon()
   {
      this.ItemIcon.gotoAndStop(this.iconLabel);
      var _loc2_ = new flash.geom.ColorTransform();
      var _loc3_ = new flash.geom.Transform(MovieClip(this.ItemIcon));
      _loc2_.rgb = Widgets.TrueHUD_RecentLootEntry.iconTint(this.iconColor,this.iconLabel);
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
   function showWords(a_name, a_count, a_size)
   {
      var _loc2_ = a_name + a_count;
      this.dovName.text = _loc2_;
      this.dovName.setTextFormat(this.format(a_size,Widgets.TrueHUD_RecentLootEntry.GOLD_INK));
      if(a_count.length > 0)
      {
         this.dovName.setTextFormat(a_name.length,_loc2_.length,this.format(a_size,Widgets.TrueHUD_RecentLootEntry.GOLD_DIM));
      }
      return this.dovName.textWidth;
   }
   function updateName()
   {
      var _loc3_ = this.itemName != undefined ? String(this.itemName) : "";
      var _loc5_ = "";
      if(this.itemCount > 1)
      {
         _loc5_ = " (" + this.itemCount.toString() + ")";
      }
      var _loc2_ = Widgets.TrueHUD_RecentLootEntry.SIZE;
      var _loc4_ = this.showWords(_loc3_,_loc5_,_loc2_);
      while(_loc4_ > Widgets.TrueHUD_RecentLootEntry.MOST && _loc2_ > Widgets.TrueHUD_RecentLootEntry.LEAST_SIZE)
      {
         _loc2_ = _loc2_ - 1;
         _loc4_ = this.showWords(_loc3_,_loc5_,_loc2_);
      }
      var _loc6_ = _loc3_;
      while(_loc4_ > Widgets.TrueHUD_RecentLootEntry.MOST && _loc6_.length > 1)
      {
         _loc6_ = _loc6_.substr(0,_loc6_.length - 1);
         while(_loc6_.length > 1 && _loc6_.charAt(_loc6_.length - 1) == " ")
         {
            _loc6_ = _loc6_.substr(0,_loc6_.length - 1);
         }
         _loc4_ = this.showWords(_loc6_ + "...",_loc5_,_loc2_);
      }
      this.dovName._y = Math.round((- _loc2_) * 0.95 / 2) - 2;
      this.layoutGround(_loc4_);
   }
   function layoutGround(a_textWidth)
   {
      var _loc2_ = this.dovGround;
      _loc2_.clear();
      var _loc7_ = Widgets.TrueHUD_RecentLootEntry.BAND_H;
      var _loc5_ = (- _loc7_) / 2;
      var _loc3_ = Widgets.TrueHUD_RecentLootEntry.TEXT_RIGHT - a_textWidth - Widgets.TrueHUD_RecentLootEntry.RUN;
      var _loc4_ = Widgets.TrueHUD_RecentLootEntry.END - _loc3_;
      var _loc6_ = Math.round(255 * Widgets.TrueHUD_RecentLootEntry.RUN / _loc4_);
      var _loc10_ = Math.round(255 * (Widgets.TrueHUD_RecentLootEntry.ICON_LEFT + Widgets.TrueHUD_RecentLootEntry.ICON - _loc3_) / _loc4_);
      var _loc11_ = Math.round(255 * (Widgets.TrueHUD_RecentLootEntry.ICON_LEFT + Widgets.TrueHUD_RecentLootEntry.ICON / 2 - _loc3_) / _loc4_);
      this.grad(_loc2_,_loc3_,_loc5_,_loc4_,_loc7_,[Widgets.TrueHUD_RecentLootEntry.NIGHT,Widgets.TrueHUD_RecentLootEntry.NIGHT,Widgets.TrueHUD_RecentLootEntry.NIGHT,Widgets.TrueHUD_RecentLootEntry.NIGHT],[0,Widgets.TrueHUD_RecentLootEntry.SHADE,Widgets.TrueHUD_RecentLootEntry.SHADE,0],[0,_loc6_,_loc10_,255]);
      this.grad(_loc2_,_loc3_,_loc5_,_loc4_,1,[Widgets.TrueHUD_RecentLootEntry.GOLD_BORDER,Widgets.TrueHUD_RecentLootEntry.GOLD,Widgets.TrueHUD_RecentLootEntry.GOLD_BORDER],[0,Widgets.TrueHUD_RecentLootEntry.LINE,0],[0,_loc11_,255]);
      this.grad(_loc2_,_loc3_,_loc5_ + _loc7_ - 1,_loc4_,1,[Widgets.TrueHUD_RecentLootEntry.GOLD_BORDER,Widgets.TrueHUD_RecentLootEntry.GOLD,Widgets.TrueHUD_RecentLootEntry.GOLD_BORDER],[0,Widgets.TrueHUD_RecentLootEntry.LINE,0],[0,_loc11_,255]);
      var _loc8_ = Widgets.TrueHUD_RecentLootEntry.ICON_LEFT + Widgets.TrueHUD_RecentLootEntry.ICON / 2;
      var _loc9_ = Widgets.TrueHUD_RecentLootEntry.DISC;
      _loc2_.beginGradientFill("radial",[Widgets.TrueHUD_RecentLootEntry.NIGHT,Widgets.TrueHUD_RecentLootEntry.NIGHT],[Widgets.TrueHUD_RecentLootEntry.DISC_SHADE,0],[0,255],{matrixType:"box",x:_loc8_ - _loc9_,y:- _loc9_,w:_loc9_ * 2,h:_loc9_ * 2,r:0});
      _loc2_.moveTo(_loc8_ - _loc9_,- _loc9_);
      _loc2_.lineTo(_loc8_ + _loc9_,- _loc9_);
      _loc2_.lineTo(_loc8_ + _loc9_,_loc9_);
      _loc2_.lineTo(_loc8_ - _loc9_,_loc9_);
      _loc2_.lineTo(_loc8_ - _loc9_,- _loc9_);
      _loc2_.endFill();
   }
   function grad(a_mc, a_x, a_y, a_w, a_h, a_colours, a_alphas, a_ratios)
   {
      if(a_w <= 0 || a_h <= 0)
      {
         return undefined;
      }
      a_mc.beginGradientFill("linear",a_colours,a_alphas,a_ratios,{matrixType:"box",x:a_x,y:a_y,w:a_w,h:a_h,r:0});
      a_mc.moveTo(a_x,a_y);
      a_mc.lineTo(a_x + a_w,a_y);
      a_mc.lineTo(a_x + a_w,a_y + a_h);
      a_mc.lineTo(a_x,a_y + a_h);
      a_mc.lineTo(a_x,a_y);
      a_mc.endFill();
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
