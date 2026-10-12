class Widgets.TrueHUD_InfoBar extends Widgets.TrueHUD_InfoBarBase
{
   var Bars;
   var DamageCounter;
   var Indicator;
   var IndicatorMask;
   var TargetName;
   var bDisplayDamageCounter;
   var bDisplayIndicator;
   var bDisplayPhantomBars;
   var bDisplaySpecialPhantomBar;
   var bHealthBarHasFlash;
   var bHealthBarHasShapeMask;
   var bSpecialDefaultMode;
   var damageCounterY;
   var fCurrentResourceWidth;
   var fCurrentWidth;
   var fDamageCounterDuration;
   var fOpacity;
   var fPhantomDuration;
   var fResourceWidth;
   var fTargetResourceWidth;
   var fTargetWidth;
   var fWidth;
   var healthXOffset;
   var hideIndicatorTimeline;
   var killDelay;
   var magickaWidthOffset;
   var nameFadeTimeline;
   var nameY;
   var onEnterFrame;
   var resourcesFrameOutlineWidthOffset;
   var resourcesFrameWidthOffset;
   var resourcesXOffsetOne;
   var resourcesXOffsetTwo;
   var resourcesYBoth;
   var resourcesYNone;
   var resourcesYStamina;
   var showIndicatorTimeline;
   var specialFrameOutlineWidthOffset;
   var specialFrameWidthOffset;
   var specialYHidden;
   var specialYShown;
   var targetType;
   var toggleResources;
   var toggleSpecial;
   var uBarDirection;
   var uDamageCounterAlignment;
   var uDisplayDamageCounter;
   var uDisplayIndicator;
   var uDisplayName;
   var uDisplayedResources;
   var uHealthBackgroundColor;
   var uHealthColor;
   var uHealthFlashColor;
   var uHealthPenaltyColor;
   var uHealthPhantomColor;
   var uIndicatorMode;
   var uMagickaBackgroundColor;
   var uMagickaColor;
   var uMagickaFlashColor;
   var uMagickaPenaltyColor;
   var uMagickaPhantomColor;
   var uResourcesModeHostiles;
   var uResourcesModeOthers;
   var uResourcesModeTarget;
   var uResourcesModeTeammates;
   var uSpecialBackgroundColor;
   var uSpecialColor;
   var uSpecialFlashColor;
   var uSpecialModeHostiles;
   var uSpecialModeOthers;
   var uSpecialModeTarget;
   var uSpecialModeTeammates;
   var uSpecialPenaltyColor;
   var uSpecialPhantomColor;
   var uStaminaBackgroundColor;
   var uStaminaColor;
   var uStaminaFlashColor;
   var uStaminaPenaltyColor;
   var uStaminaPhantomColor;
   var updateDamageY;
   var updateNameY;
   var widthTimeline;
   var widthTimelineDuration = 0.25;
   function TrueHUD_InfoBar()
   {
      super();
      this.nameFadeTimeline = new com.greensock.TimelineLite({paused:true});
      this.showIndicatorTimeline = new com.greensock.TimelineLite({paused:true});
      this.hideIndicatorTimeline = new com.greensock.TimelineLite({paused:true});
      this.widthTimeline = new com.greensock.TimelineLite({paused:true});
      this.bHealthBarHasFlash = true;
      this.bHealthBarHasShapeMask = true;
      this.healthXOffset = 15;
      this.killDelay = 2;
      this.nameY = -30;
      this.damageCounterY = 2;
      this.resourcesYNone = 2.5;
      this.resourcesYStamina = 8.5;
      this.resourcesYBoth = 11.5;
      this.specialYHidden = -3.5;
      this.specialYShown = -9.5;
      this.bLiftWithResources = true;
      this.Bars.Resources._y = 2.5;
      this.Bars.Special._y = -3.5;
      this.Indicator._alpha = 0;
      this.TargetName._alpha = 0;
      this.TargetName.autoSize = "center";
      this.nameFadeTimeline["set"](this.TargetName,{_alpha:0});
      this.nameFadeTimeline.to(this.TargetName,0.25,{_alpha:100},0);
   }
   function init()
   {
      super.init();
      if(this.targetType == 0)
      {
         this.setWidth(this.fTargetWidth,this.fTargetResourceWidth);
      }
      else
      {
         this.setWidth(this.fWidth,this.fResourceWidth);
      }
      this.showIndicatorTimeline.clear();
      this.showIndicatorTimeline["set"](this.Indicator,{_visible:true});
      this.showIndicatorTimeline.to(this.Indicator,0.25,{_alpha:100,ease:com.greensock.easing.Sine.easeIn},0);
      this.showIndicatorTimeline.call(this.toggleIndicatorMask,[true],this);
      this.hideIndicatorTimeline.clear();
      this.hideIndicatorTimeline.call(this.toggleIndicatorMask,[false],this);
      this.hideIndicatorTimeline.to(this.Indicator,0.25,{_alpha:0,ease:com.greensock.easing.Sine.easeIn},0);
      this.hideIndicatorTimeline["set"](this.Indicator,{_visible:false});
   }
   function cleanUp()
   {
      super.cleanUp();
      this.nameFadeTimeline.clear();
      this.nameFadeTimeline.kill();
      this.nameFadeTimeline = null;
      this.showIndicatorTimeline.clear();
      this.showIndicatorTimeline.kill();
      this.showIndicatorTimeline = null;
      this.hideIndicatorTimeline.clear();
      this.hideIndicatorTimeline.kill();
      this.hideIndicatorTimeline = null;
      this.widthTimeline.clear();
      this.widthTimeline.kill();
      this.widthTimeline = null;
   }
   function toggleIndicator(a_enable)
   {
      super.toggleIndicator(a_enable);
      if(a_enable == this.bDisplayIndicator)
      {
         return undefined;
      }
      this.bDisplayIndicator = a_enable;
      if(this.bDisplayIndicator)
      {
         this.hideIndicatorTimeline.pause();
         this.showIndicatorTimeline.restart();
      }
      else
      {
         this.showIndicatorTimeline.pause();
         this.hideIndicatorTimeline.restart();
      }
   }
   function calculateDamageCounterY()
   {
      var _loc3_ = 0;
      switch(this.uDisplayedResources)
      {
         case 0:
            break;
         case 1:
            _loc3_ = this.resourcesXOffsetOne;
            break;
         case 2:
            _loc3_ = this.resourcesXOffsetTwo;
      }
      var _loc4_ = this.fCurrentWidth + this.healthXOffset;
      if((_loc4_ - (this.fCurrentResourceWidth + _loc3_)) / 2 > this.DamageCounter.textWidth)
      {
         return this.damageCounterY + this.calculateLiftY();
      }
      return super.calculateDamageCounterY();
   }
   function updateTargetType(a_newTargetType)
   {
      var _loc4_ = this.targetType;
      if(this.uDisplayIndicator > a_newTargetType)
      {
         this.toggleIndicator(true);
      }
      else
      {
         this.toggleIndicator(false);
      }
      super.updateTargetType(a_newTargetType);
      if(this.uDisplayName > a_newTargetType)
      {
         this.nameFadeTimeline.play();
      }
      else
      {
         this.nameFadeTimeline.reverse();
      }
      if(this.uDisplayDamageCounter > a_newTargetType)
      {
         this.bDisplayDamageCounter = true;
         this.DamageCounter._visible = true;
      }
      else
      {
         this.bDisplayDamageCounter = false;
         this.DamageCounter._visible = false;
      }
      if(a_newTargetType == 0)
      {
         this.setWidthTimeline(this.fTargetWidth,this.fTargetResourceWidth);
      }
      else if(_loc4_ == 0)
      {
         this.setWidthTimeline(this.fWidth,this.fResourceWidth);
      }
      switch(a_newTargetType)
      {
         case 0:
            this.toggleResources(this.uResourcesModeTarget);
            this.toggleSpecial(this.uSpecialModeTarget);
            break;
         case 1:
            this.toggleResources(this.uResourcesModeHostiles);
            this.toggleSpecial(this.uSpecialModeHostiles);
            break;
         case 2:
            this.toggleResources(this.uResourcesModeTeammates);
            this.toggleSpecial(this.uSpecialModeTeammates);
            break;
         case 3:
            this.toggleResources(this.uResourcesModeOthers);
            this.toggleSpecial(this.uSpecialModeOthers);
         default:
            return;
      }
   }
   function setWidth(a_width, a_resourceWidth)
   {
      super.setWidth(a_width,a_resourceWidth);
      var _loc3_ = -60.5;
      if(a_width != 100)
      {
         _loc3_ = -60.5 - (a_width - 100) / 2;
      }
      this.Indicator._x = _loc3_;
      this.IndicatorMask._x = _loc3_;
   }
   function toggleIndicatorMask(a_enable)
   {
      if(a_enable)
      {
         this.Bars.setMask(this.IndicatorMask);
      }
      else
      {
         this.Bars.setMask(null);
      }
   }
   function loadConfig(a_uInfoBarDirection, a_uInfoBarDisplayName, a_bInfoBarDisplayPhantomBars, a_bInfoBarDisplaySpecialPhantomBar, a_uInfoBarDisplayDamageCounter, a_uInfoBarDisplayIndicator, a_uInfoBarDamageCounterAlignment, a_uInfoBarResourcesModeTarget, a_uInfoBarResourcesModeHostiles, a_uInfoBarResourcesModeTeammates, a_uInfoBarResourcesModeOthers, a_uInfoBarSpecialModeTarget, a_uInfoBarSpecialModeHostiles, a_uInfoBarSpecialModeTeammates, a_uInfoBarSpecialModeOthers, a_bInfoBarSpecialDefaultMode, a_uInfoBarIndicatorMode, a_fInfoBarPhantomDuration, a_fInfoBarDamageCounterDuration, a_fInfoBarOpacity, a_fInfoBarWidth, a_fInfoBarResourceWidth, a_fInfoBarTargetWidth, a_fInfoBarTargetResourceWidth, a_uHealthColor, a_uHealthPhantomColor, a_uHealthBackgroundColor, a_uHealthPenaltyColor, a_uHealthFlashColor, a_uMagickaColor, a_uMagickaPhantomColor, a_uMagickaBackgroundColor, a_uMagickaPenaltyColor, a_uMagickaFlashColor, a_uStaminaColor, a_uStaminaPhantomColor, a_uStaminaBackgroundColor, a_uStaminaPenaltyColor, a_uStaminaFlashColor, a_uSpecialColor, a_uSpecialPhantomColor, a_uSpecialBackgroundColor, a_uSpecialPenaltyColor, a_uSpecialFlashColor)
   {
      this.uBarDirection = a_uInfoBarDirection;
      this.uDisplayName = a_uInfoBarDisplayName;
      this.bDisplayPhantomBars = a_bInfoBarDisplayPhantomBars;
      this.bDisplaySpecialPhantomBar = a_bInfoBarDisplaySpecialPhantomBar;
      this.uDisplayDamageCounter = a_uInfoBarDisplayDamageCounter;
      this.uDisplayIndicator = a_uInfoBarDisplayIndicator;
      this.uDamageCounterAlignment = a_uInfoBarDamageCounterAlignment;
      this.uResourcesModeTarget = a_uInfoBarResourcesModeTarget;
      this.uResourcesModeHostiles = a_uInfoBarResourcesModeHostiles;
      this.uResourcesModeTeammates = a_uInfoBarResourcesModeTeammates;
      this.uResourcesModeOthers = a_uInfoBarResourcesModeOthers;
      this.uSpecialModeTarget = a_uInfoBarSpecialModeTarget;
      this.uSpecialModeHostiles = a_uInfoBarSpecialModeHostiles;
      this.uSpecialModeTeammates = a_uInfoBarSpecialModeTeammates;
      this.uSpecialModeOthers = a_uInfoBarSpecialModeOthers;
      this.bSpecialDefaultMode = a_bInfoBarSpecialDefaultMode;
      this.uIndicatorMode = a_uInfoBarIndicatorMode;
      this.fPhantomDuration = a_fInfoBarPhantomDuration;
      this.fDamageCounterDuration = a_fInfoBarDamageCounterDuration;
      this.fOpacity = a_fInfoBarOpacity;
      this.fWidth = a_fInfoBarWidth;
      this.fResourceWidth = a_fInfoBarResourceWidth;
      this.fTargetWidth = a_fInfoBarTargetWidth;
      this.fTargetResourceWidth = a_fInfoBarTargetResourceWidth;
      this.uHealthColor = a_uHealthColor;
      this.uHealthPhantomColor = a_uHealthPhantomColor;
      this.uHealthBackgroundColor = a_uHealthBackgroundColor;
      this.uHealthPenaltyColor = a_uHealthPenaltyColor;
      this.uHealthFlashColor = a_uHealthFlashColor;
      this.uMagickaColor = a_uMagickaColor;
      this.uMagickaPhantomColor = a_uMagickaPhantomColor;
      this.uMagickaBackgroundColor = a_uMagickaBackgroundColor;
      this.uMagickaPenaltyColor = a_uMagickaPenaltyColor;
      this.uMagickaFlashColor = a_uMagickaFlashColor;
      this.uStaminaColor = a_uStaminaColor;
      this.uStaminaPhantomColor = a_uStaminaPhantomColor;
      this.uStaminaBackgroundColor = a_uStaminaBackgroundColor;
      this.uStaminaPenaltyColor = a_uStaminaPenaltyColor;
      this.uStaminaFlashColor = a_uStaminaFlashColor;
      this.uSpecialColor = a_uSpecialColor;
      this.uSpecialPhantomColor = a_uSpecialPhantomColor;
      this.uSpecialBackgroundColor = a_uSpecialBackgroundColor;
      this.uSpecialPenaltyColor = a_uSpecialPenaltyColor;
      this.uSpecialFlashColor = a_uSpecialFlashColor;
      this.onEnterFrame = function()
      {
         this.init();
         delete this.onEnterFrame;
      };
   }
   function setWidthTimeline(a_width, a_resourceWidth)
   {
      this.fCurrentWidth = a_width;
      this.fCurrentResourceWidth = a_resourceWidth;
      this.widthTimeline.clear();
      this.Bars.HealthBar.setWidthTimeline(a_width);
      this.Bars.Resources.MagickaBar.setWidthTimeline(a_resourceWidth + this.magickaWidthOffset);
      this.Bars.Resources.StaminaBar.setWidthTimeline(a_resourceWidth);
      this.Bars.Special.SpecialBar.setWidthTimeline(a_resourceWidth);
      this.widthTimeline.to(this.Bars.ResourceMask,this.widthTimelineDuration,{_xscale:a_resourceWidth + this.resourcesFrameWidthOffset,ease:com.greensock.easing.Sine.easeIn},0).to(this.Bars.Resources.Frame,this.widthTimelineDuration,{_width:a_resourceWidth + this.resourcesFrameWidthOffset,ease:com.greensock.easing.Sine.easeIn},0).to(this.Bars.Resources.Outline,this.widthTimelineDuration,{_width:a_resourceWidth + this.resourcesFrameOutlineWidthOffset,ease:com.greensock.easing.Sine.easeIn},0).to(this.Bars.Special.Frame,this.widthTimelineDuration,{_width:a_resourceWidth + this.specialFrameWidthOffset,ease:com.greensock.easing.Sine.easeIn},0).to(this.Bars.Special.Outline,this.widthTimelineDuration,{_width:a_resourceWidth + this.specialFrameOutlineWidthOffset,ease:com.greensock.easing.Sine.easeIn},0);
      var _loc5_ = a_width + this.healthXOffset;
      this.widthTimeline.to(this.DamageCounter,this.widthTimelineDuration,{_width:_loc5_,ease:com.greensock.easing.Sine.easeIn},0).to(this.DamageCounter,this.widthTimelineDuration,{_x:(- _loc5_) / 2,ease:com.greensock.easing.Sine.easeIn},0);
      var _loc3_ = -60.5;
      if(a_width != 100)
      {
         _loc3_ = -60.5 - (a_width - 100) / 2;
      }
      this.widthTimeline.to(this.Indicator,this.widthTimelineDuration,{_x:_loc3_,ease:com.greensock.easing.Sine.easeIn},0).to(this.IndicatorMask,this.widthTimelineDuration,{_x:_loc3_,ease:com.greensock.easing.Sine.easeIn},0);
      this.widthTimeline.restart();
      this.updateNameY();
      this.updateDamageY();
   }
}
