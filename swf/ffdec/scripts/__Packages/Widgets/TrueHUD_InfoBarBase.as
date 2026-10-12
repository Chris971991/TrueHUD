class Widgets.TrueHUD_InfoBarBase extends MovieClip
{
   var Bars;
   var DamageCounter;
   var Indicator;
   var IndicatorMask;
   var TargetName;
   var bSpecialDefaultMode;
   var damageTimeline;
   var damageYTween;
   var depth;
   var fDamageCounterDuration;
   var fDesiredDamageCounterY;
   var fDesiredNameY;
   var fOpacity;
   var fPhantomDuration;
   var frameWidthOffset;
   var levelColor;
   var nameYTween;
   var outlineColor;
   var outlineWidthOffset;
   var resourcesFrameOutlineWidthOffset;
   var resourcesFrameWidthOffset;
   var resourcesTween;
   var bLiftWithResources = false;
   var fDesiredLiftY = 0;
   var liftTweenBars;
   var liftTweenIndicator;
   var liftTweenIndicatorMask;
   var showHideTimeline;
   var soulType;
   var specialFrameOutlineWidthOffset;
   var specialFrameWidthOffset;
   var specialOutlineFlashWidthOffset;
   var specialTween;
   var targetKilledTimeline;
   var targetLevel;
   var targetType;
   var toggleWidgetTimeline;
   var uBarDirection;
   var uDamageCounterAlignment;
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
   var uSpecialBackgroundColor;
   var uSpecialColor;
   var uSpecialFlashColor;
   var uSpecialPenaltyColor;
   var uSpecialPhantomColor;
   var uStaminaBackgroundColor;
   var uStaminaColor;
   var uStaminaFlashColor;
   var uStaminaPenaltyColor;
   var uStaminaPhantomColor;
   var widgetState = 2;
   var maxHealth = -1;
   var health = -1;
   var healthPct = -1;
   var maxMagicka = -1;
   var magicka = -1;
   var magickaPct = -1;
   var maxStamina = -1;
   var stamina = -1;
   var staminaPct = -1;
   var maxSpecial = -1;
   var special = -1;
   var specialPct = -1;
   var damage = 0;
   var bInitialized = false;
   var bHidden = false;
   var bReadyToRemove = false;
   var uResourcesMode = 0;
   var uSpecialMode = 0;
   var fCurrentWidth = 0;
   var fCurrentResourceWidth = 0;
   var uDisplayedResources = 0;
   var bDisplayedSpecial = false;
   var bMagickaChangedFromDefault = false;
   var bStaminaChangedFromDefault = false;
   var bSpecialChangedFromDefault = false;
   var bSpecialHitThreshold = false;
   var bDisplayPhantomBars = false;
   var bDisplaySpecialPhantomBar = false;
   var bDisplayDamageCounter = false;
   var bDisplayIndicator = false;
   var bHealthBarHasShadow = false;
   var bHealthBarHasShapeMask = false;
   var bHealthBarHasFlash = false;
   var magickaWidthOffset = 6;
   var specialNameOffset = -6;
   var resourcesYOffsetOne = 6;
   var resourcesYOffsetTwo = 9;
   var resourcesXOffsetOne = 12;
   var resourcesXOffsetTwo = 18;
   var healthXOffset = 0;
   var killDelay = 0;
   var nameY = 0;
   var damageCounterY = 0;
   var resourcesYNone = 0;
   var resourcesYStamina = 0;
   var resourcesYBoth = 0;
   var specialYHidden = 0;
   var specialYShown = 0;
   function TrueHUD_InfoBarBase()
   {
      super();
      this.stop();
      this.showHideTimeline = new com.greensock.TimelineLite({paused:true});
      this.toggleWidgetTimeline = new com.greensock.TimelineLite({paused:true});
      this.targetKilledTimeline = new com.greensock.TimelineLite({paused:true});
      this.damageTimeline = new com.greensock.TimelineLite({paused:true});
      this.Indicator._visible = false;
      this.IndicatorMask._visible = false;
      this.TargetName._alpha = 0;
      this.DamageCounter._alpha = 0;
      this.resourcesFrameWidthOffset = this.Bars.Resources.Frame._width - 100;
      this.resourcesFrameOutlineWidthOffset = this.Bars.Resources.Outline._width - 100;
      this.specialFrameWidthOffset = this.Bars.Special.Frame._width - 100;
      this.specialFrameOutlineWidthOffset = this.Bars.Special.Outline._width - 100;
      this.specialOutlineFlashWidthOffset = this.Bars.Special.SpecialBar.Flash._width - 100;
      this.frameWidthOffset = this.Bars.HealthBar.Frame._width - 100;
      this.outlineWidthOffset = this.Bars.HealthBar.Outline._width - 100;
      this.targetType = -1;
      this.fOpacity = 0;
      this._alpha = 0;
   }
   function init()
   {
      this.Bars.HealthBar.init(this.bDisplayPhantomBars,this.fPhantomDuration,this.uBarDirection,true,this.bHealthBarHasShadow,this.bHealthBarHasShapeMask,this.bHealthBarHasFlash,false);
      this.Bars.HealthBar.setColor(this.uHealthColor,this.uHealthPhantomColor,this.uHealthBackgroundColor,this.uHealthPenaltyColor,this.uHealthFlashColor);
      this.Bars.Resources.MagickaBar.init(this.bDisplayPhantomBars,this.fPhantomDuration,this.uBarDirection,false,false,true,false,false);
      this.Bars.Resources.MagickaBar.setColor(this.uMagickaColor,this.uMagickaPhantomColor,this.uMagickaBackgroundColor,this.uMagickaPenaltyColor,this.uMagickaFlashColor);
      this.Bars.Resources.StaminaBar.init(this.bDisplayPhantomBars,this.fPhantomDuration,this.uBarDirection,false,false,true,false,false);
      this.Bars.Resources.StaminaBar.setColor(this.uStaminaColor,this.uStaminaPhantomColor,this.uStaminaBackgroundColor,this.uStaminaPenaltyColor,this.uStaminaFlashColor);
      this.Bars.Special.SpecialBar.init(this.bDisplaySpecialPhantomBar,this.fPhantomDuration,this.uBarDirection,false,false,true,true,false);
      this.Bars.Special.SpecialBar.setColor(this.uSpecialColor,this.uSpecialPhantomColor,this.uSpecialBackgroundColor,this.uSpecialPenaltyColor,this.uSpecialFlashColor);
      this.switchIndicatorMode();
      this.showHideTimeline.clear();
      this.showHideTimeline["set"](this,{_alpha:0},0);
      this.showHideTimeline.to(this,0.25,{_alpha:this.fOpacity},0);
      this.showHideTimeline.eventCallback("onStart",this.setHidden,[false],this);
      this.showHideTimeline.eventCallback("onReverseComplete",this.setHidden,[true],this);
      this.toggleWidgetTimeline.clear();
      this.toggleWidgetTimeline["set"](this,{_alpha:0},0);
      this.toggleWidgetTimeline.to(this,0.25,{_alpha:this.fOpacity},0);
      this.toggleWidgetTimeline.eventCallback("onStart",this.setReadyToRemove,[false],this);
      this.toggleWidgetTimeline.eventCallback("onReverseComplete",this.setReadyToRemove,[true],this);
      this.targetKilledTimeline.clear();
      this.targetKilledTimeline.to(this,0.25,{_alpha:0},this.killDelay);
      this.targetKilledTimeline.call(this.setReadyToRemove,[true],this);
      this.damageTimeline.clear();
      this.damageTimeline["set"](this.DamageCounter,{_alpha:100},0);
      this.damageTimeline.to(this.DamageCounter,0,{_alpha:0},this.fDamageCounterDuration);
      this.damageTimeline.eventCallback("onComplete",this.resetDamage,null,this);
      var _loc2_ = new TextFormat();
      switch(this.uDamageCounterAlignment)
      {
         case 0:
            _loc2_.align = "center";
            break;
         case 1:
            _loc2_.align = "left";
            break;
         case 2:
            _loc2_.align = "right";
      }
      this.DamageCounter.setTextFormat(_loc2_);
      this.DamageCounter.setNewTextFormat(_loc2_);
      this.bInitialized = true;
   }
   function cleanUp()
   {
      this.Bars.HealthBar.cleanUp();
      this.Bars.Resources.MagickaBar.cleanUp();
      this.Bars.Resources.StaminaBar.cleanUp();
      this.Bars.Special.SpecialBar.cleanUp();
      this.showHideTimeline.eventCallback("onStart",null);
      this.showHideTimeline.eventCallback("onReverseComplete",null);
      this.showHideTimeline.clear();
      this.showHideTimeline.kill();
      this.showHideTimeline = null;
      this.toggleWidgetTimeline.eventCallback("onStart",null);
      this.toggleWidgetTimeline.eventCallback("onReverseComplete",null);
      this.toggleWidgetTimeline.clear();
      this.toggleWidgetTimeline.kill();
      this.toggleWidgetTimeline = null;
      this.targetKilledTimeline.clear();
      this.targetKilledTimeline.kill();
      this.targetKilledTimeline = null;
      this.damageTimeline.clear();
      this.damageTimeline.kill();
      this.damageTimeline = null;
      this.resourcesTween.kill();
      this.resourcesTween = null;
      this.specialTween.kill();
      this.specialTween = null;
      this.nameYTween.kill();
      this.nameYTween = null;
      this.damageYTween.kill();
      this.damageYTween = null;
   }
   function setHidden(a_hidden)
   {
      this.bHidden = a_hidden;
   }
   function setReadyToRemove(a_readyToRemove)
   {
      this.bReadyToRemove = a_readyToRemove;
   }
   function toggleVisibility(a_show)
   {
      if(a_show)
      {
         if(this.showHideTimeline.progress() == 1)
         {
            this.showHideTimeline.play(0);
         }
         else
         {
            this.showHideTimeline.play();
         }
      }
      else if(this.showHideTimeline.progress() == 0)
      {
         this.showHideTimeline.reverse(0);
      }
      else
      {
         this.showHideTimeline.reverse();
      }
   }
   function toggleWidget(a_show)
   {
      if(a_show)
      {
         if(this.toggleWidgetTimeline.progress() == 1)
         {
            this.toggleWidgetTimeline.play(0);
         }
         else
         {
            this.toggleWidgetTimeline.play();
         }
      }
      else if(this.toggleWidgetTimeline.progress() == 0)
      {
         this.toggleWidgetTimeline.reverse(0);
      }
      else
      {
         this.toggleWidgetTimeline.reverse();
      }
   }
   function targetKilled()
   {
      if(this.uDisplayedResources > 0)
      {
         this.moveResources(0);
      }
      if(this.bDisplayedSpecial)
      {
         this.moveSpecial(false);
      }
      this.targetKilledTimeline.play();
   }
   function switchIndicatorMode()
   {
      switch(this.uIndicatorMode)
      {
         case 0:
            this.Indicator.SoulIcon._visible = true;
            this.Indicator.LevelText._visible = false;
            this.Indicator.LevelIcon._visible = false;
            break;
         case 1:
            this.Indicator.SoulIcon._visible = false;
            this.Indicator.LevelText._visible = true;
            this.Indicator.LevelIcon._visible = false;
            break;
         case 2:
            this.Indicator.SoulIcon._visible = false;
            this.Indicator.LevelText._visible = false;
            this.Indicator.LevelIcon._visible = true;
         default:
            return;
      }
   }
   function toggleIndicator(a_enable)
   {
   }
   function updateTargetType(a_newTargetType)
   {
      this.targetType = a_newTargetType;
   }
   function calculateDamageCounterY()
   {
      switch(this.uDisplayedResources)
      {
         case 0:
            return this.damageCounterY + this.calculateLiftY();
         case 1:
            return this.damageCounterY + this.resourcesYOffsetOne + this.calculateLiftY();
         case 2:
            return this.damageCounterY + this.resourcesYOffsetTwo + this.calculateLiftY();
         default:
            return;
      }
   }
   function calculateNameY()
   {
      if(this.bDisplayedSpecial)
      {
         return this.nameY + this.specialNameOffset + this.calculateLiftY();
      }
      return this.nameY + this.calculateLiftY();
   }
   function calculateLiftY()
   {
      if(!this.bLiftWithResources)
      {
         return 0;
      }
      switch(this.uDisplayedResources)
      {
         case 1:
            return - this.resourcesYOffsetOne;
         case 2:
            return - this.resourcesYOffsetTwo;
         default:
            return 0;
      }
   }
   function updateLiftY()
   {
      var _loc2_ = this.calculateLiftY();
      if(this.fDesiredLiftY != _loc2_)
      {
         this.fDesiredLiftY = _loc2_;
         this.liftTweenBars = com.greensock.TweenLite.to(this.Bars,0.25,{_y:_loc2_,ease:com.greensock.easing.Sine.easeIn});
         this.liftTweenIndicator = com.greensock.TweenLite.to(this.Indicator,0.25,{_y:_loc2_,ease:com.greensock.easing.Sine.easeIn});
         this.liftTweenIndicatorMask = com.greensock.TweenLite.to(this.IndicatorMask,0.25,{_y:_loc2_,ease:com.greensock.easing.Sine.easeIn});
      }
   }
   function updateDamageY()
   {
      var _loc2_ = this.calculateDamageCounterY();
      if(this.fDesiredDamageCounterY != _loc2_)
      {
         this.fDesiredDamageCounterY = _loc2_;
         this.damageYTween = com.greensock.TweenLite.to(this.DamageCounter,0.1,{_y:_loc2_,ease:com.greensock.easing.Sine.easeIn});
      }
   }
   function updateNameY()
   {
      var _loc2_ = this.calculateNameY();
      if(this.fDesiredNameY != _loc2_)
      {
         this.fDesiredNameY = _loc2_;
         this.nameYTween = com.greensock.TweenLite.to(this.TargetName,0.1,{_y:_loc2_,ease:com.greensock.easing.Sine.easeIn});
      }
   }
   function moveResources(a_mode)
   {
      switch(a_mode)
      {
         case 0:
            this.uDisplayedResources = 0;
            this.resourcesTween = com.greensock.TweenLite.to(this.Bars.Resources,0.25,{_y:this.resourcesYNone,ease:com.greensock.easing.Sine.easeIn},0);
            break;
         case 1:
            this.uDisplayedResources = 1;
            this.resourcesTween = com.greensock.TweenLite.to(this.Bars.Resources,0.25,{_y:this.resourcesYStamina,ease:com.greensock.easing.Sine.easeIn},0);
            break;
         case 2:
            this.uDisplayedResources = 2;
            this.resourcesTween = com.greensock.TweenLite.to(this.Bars.Resources,0.25,{_y:this.resourcesYBoth,ease:com.greensock.easing.Sine.easeIn},0);
      }
      this.updateLiftY();
      this.updateDamageY();
      this.updateNameY();
   }
   function toggleResources(a_mode)
   {
      if(a_mode == this.uResourcesMode)
      {
         return undefined;
      }
      this.uResourcesMode = a_mode;
      switch(a_mode)
      {
         case 0:
            if(this.uDisplayedResources != 0)
            {
               this.moveResources(0);
            }
            break;
         case 1:
            if(this.bMagickaChangedFromDefault)
            {
               if(this.uDisplayedResources < 2)
               {
                  this.moveResources(2);
               }
            }
            else if(this.bStaminaChangedFromDefault)
            {
               if(this.uDisplayedResources < 1)
               {
                  this.moveResources(1);
               }
            }
            else if(this.uDisplayedResources > 0)
            {
               this.moveResources(0);
            }
            break;
         case 2:
            if(this.uDisplayedResources < 2)
            {
               this.moveResources(2);
            }
         default:
            return;
      }
   }
   function moveSpecial(a_enable)
   {
      if(a_enable)
      {
         this.bDisplayedSpecial = true;
         this.Bars.Special.Flash._visible = true;
         this.specialTween = com.greensock.TweenLite.to(this.Bars.Special,0.25,{_y:this.specialYShown,ease:com.greensock.easing.Sine.easeIn});
      }
      else
      {
         this.bDisplayedSpecial = false;
         this.Bars.Special.Flash._visible = false;
         this.specialTween = com.greensock.TweenLite.to(this.Bars.Special,0.25,{_y:this.specialYHidden,ease:com.greensock.easing.Sine.easeIn});
      }
      this.updateNameY();
   }
   function toggleSpecial(a_mode)
   {
      if(a_mode == this.uSpecialMode)
      {
         return undefined;
      }
      this.uSpecialMode = a_mode;
      switch(a_mode)
      {
         case 0:
            if(this.bDisplayedSpecial == true)
            {
               this.moveSpecial(false);
            }
            break;
         case 1:
            if(this.bSpecialChangedFromDefault && this.bDisplayedSpecial == false)
            {
               this.moveSpecial(true);
            }
            else if(this.bDisplayedSpecial == true)
            {
               this.moveSpecial(false);
            }
            break;
         case 2:
            if(this.bDisplayedSpecial == false)
            {
               this.moveSpecial(true);
            }
         default:
            return;
      }
   }
   function flashAV(a_actorValue, a_bLong)
   {
      switch(a_actorValue)
      {
         case 24:
            this.Bars.HealthBar.playFlash(a_bLong);
            break;
         case 25:
            this.Bars.Resources.MagickaBar.playFlash(a_bLong);
            break;
         case 26:
            this.Bars.Resources.StaminaBar.playFlash(a_bLong);
         default:
            return;
      }
   }
   function flashSpecial(a_bLong)
   {
      if(this.bDisplayedSpecial)
      {
         this.Bars.Special.SpecialBar.playFlash(a_bLong);
      }
   }
   function updateData(a_targetType, a_widgetState, a_depth, a_targetState, a_targetName, a_targetLevel, a_levelColor, a_outlineColor, a_soulType, a_maxHealth, a_health, a_healthPct, a_maxMagicka, a_magicka, a_magickaPct, a_maxStamina, a_stamina, a_staminaPct)
   {
      this.depth = a_depth;
      if(!this.bInitialized)
      {
         return undefined;
      }
      if(a_widgetState != this.widgetState)
      {
         if(this.widgetState < 3)
         {
            if(a_widgetState == 1)
            {
               this.toggleVisibility(false);
            }
            else if(a_widgetState == 0)
            {
               this.toggleVisibility(true);
            }
         }
         if(a_widgetState == 0 && this.widgetState == 4)
         {
            this.toggleWidget(true);
         }
         else if(a_widgetState == 4)
         {
            this.toggleWidget(false);
         }
         else if(a_widgetState == 3)
         {
            this.targetKilled();
         }
         this.widgetState = a_widgetState;
      }
      if(this.TargetName.text != a_targetName)
      {
         this.TargetName.text = a_targetName;
         this.updateNameY();
      }
      this.soulType = a_soulType;
      if(a_targetType != this.targetType)
      {
         this.updateTargetType(a_targetType);
      }
      if(a_targetLevel != this.targetLevel)
      {
         this.targetLevel = a_targetLevel;
         if(this.uIndicatorMode == 1)
         {
            this.Indicator.LevelText.text = this.targetLevel.toString();
         }
         else if(this.uIndicatorMode == 0)
         {
            this.Indicator.SoulIcon._visible = true;
            this.Indicator.SoulIcon.IconDragon._visible = false;
            this.Indicator.SoulIcon.IconBlack._visible = false;
            this.Indicator.SoulIcon.IconGrand._visible = false;
            this.Indicator.SoulIcon.IconGreater._visible = false;
            this.Indicator.SoulIcon.IconCommon._visible = false;
            this.Indicator.SoulIcon.IconLesser._visible = false;
            this.Indicator.SoulIcon.IconPetty._visible = false;
            this.Indicator.SoulIcon.IconNone._visible = false;
            switch(a_soulType)
            {
               case 0:
                  this.Indicator.SoulIcon.IconNone._visible = true;
                  break;
               case 1:
                  this.Indicator.SoulIcon.IconPetty._visible = true;
                  break;
               case 2:
                  this.Indicator.SoulIcon.IconLesser._visible = true;
                  break;
               case 3:
                  this.Indicator.SoulIcon.IconCommon._visible = true;
                  break;
               case 4:
                  this.Indicator.SoulIcon.IconGreater._visible = true;
                  break;
               case 5:
                  this.Indicator.SoulIcon.IconGrand._visible = true;
                  break;
               case 6:
                  this.Indicator.SoulIcon.IconBlack._visible = true;
                  break;
               case 7:
                  this.Indicator.SoulIcon.IconDragon._visible = true;
            }
         }
      }
      if(a_levelColor != this.levelColor || a_outlineColor != this.outlineColor)
      {
         this.levelColor = a_levelColor;
         this.outlineColor = a_outlineColor;
         this.updateColor();
      }
      var _loc3_;
      var _loc5_;
      if(a_health != this.health || a_maxHealth != this.maxHealth || a_healthPct != this.healthPct)
      {
         _loc3_ = this.health - a_health;
         _loc5_ = false;
         if(this.health == -1)
         {
            _loc3_ = a_maxHealth - a_health;
            _loc5_ = true;
         }
         if(this.bDisplayDamageCounter && _loc3_ > 0)
         {
            this.addDamage(_loc3_);
         }
         this.Bars.HealthBar.updatePercent(a_healthPct,_loc5_);
         this.health = a_health;
         this.maxHealth = a_maxHealth;
         this.healthPct = a_healthPct;
      }
      if(a_magicka != this.magicka || a_maxMagicka != this.maxMagicka || a_magickaPct != this.magickaPct)
      {
         _loc5_ = false;
         if(this.magicka == -1)
         {
            _loc5_ = true;
         }
         this.Bars.Resources.MagickaBar.updatePercent(a_magickaPct,_loc5_);
         this.magicka = a_magicka;
         this.maxMagicka = a_maxMagicka;
         this.magickaPct = a_magickaPct;
         if(!this.bMagickaChangedFromDefault && this.magicka < this.maxMagicka)
         {
            this.bMagickaChangedFromDefault = true;
            if(this.uResourcesMode == 1 && this.uDisplayedResources < 2)
            {
               this.moveResources(2);
            }
         }
      }
      if(a_stamina != this.stamina || a_maxStamina != this.maxStamina || a_staminaPct != this.staminaPct)
      {
         _loc5_ = false;
         if(this.staminaPct == -1)
         {
            _loc5_ = true;
         }
         this.Bars.Resources.StaminaBar.updatePercent(a_staminaPct,_loc5_);
         this.stamina = a_stamina;
         this.maxStamina = a_maxStamina;
         this.staminaPct = a_staminaPct;
         if(!this.bStaminaChangedFromDefault && this.stamina < this.maxStamina)
         {
            this.bStaminaChangedFromDefault = true;
            if(this.uResourcesMode == 1 && this.uDisplayedResources < 1)
            {
               this.moveResources(1);
            }
         }
      }
      if(a_targetState > 2)
      {
         this.targetKilled();
      }
   }
   function updateSpecial(a_maxSpecial, a_special, a_specialPct)
   {
      if(!this.bInitialized)
      {
         return undefined;
      }
      var _loc2_;
      if(a_special != this.special || a_maxSpecial != this.maxSpecial || a_specialPct != this.specialPct)
      {
         _loc2_ = false;
         if(this.specialPct == -1)
         {
            _loc2_ = true;
         }
         this.Bars.Special.SpecialBar.updatePercent(a_specialPct,_loc2_);
         this.special = a_special;
         this.maxSpecial = a_maxSpecial;
         this.specialPct = a_specialPct;
         if(!this.bSpecialChangedFromDefault && (this.bSpecialDefaultMode && this.special < this.maxSpecial || !this.bSpecialDefaultMode && this.special != 0))
         {
            this.bSpecialChangedFromDefault = true;
            if(this.uSpecialMode == 1 && this.bDisplayedSpecial == false)
            {
               this.moveSpecial(true);
            }
         }
         if(this.bSpecialDefaultMode && this.special <= 0 || !this.bSpecialDefaultMode && this.special >= this.maxSpecial)
         {
            if(!this.bSpecialHitThreshold)
            {
               this.bSpecialHitThreshold = true;
               this.flashSpecial(true);
            }
         }
         else if(this.bSpecialHitThreshold)
         {
            this.bSpecialHitThreshold = false;
         }
      }
   }
   function updateColor()
   {
      var _loc6_ = new Color(this.Bars.HealthBar.Outline);
      var _loc5_ = new Color(this.Bars.Resources.Outline);
      var _loc3_ = new Color(this.Bars.Special.Outline);
      _loc6_.setRGB(this.outlineColor);
      _loc5_.setRGB(this.outlineColor);
      _loc3_.setRGB(this.outlineColor);
      var _loc4_;
      var _loc2_;
      switch(this.uIndicatorMode)
      {
         case 0:
            _loc4_ = new Color(this.Indicator.Frame.Outline);
            _loc4_.setRGB(this.outlineColor);
            break;
         case 1:
            this.Indicator.LevelText.textColor = this.levelColor;
            _loc4_ = new Color(this.Indicator.Frame.Outline);
            _loc4_.setRGB(this.outlineColor);
            break;
         case 2:
            _loc2_ = new Color(this.Indicator.LevelIcon);
            _loc2_.setRGB(this.levelColor);
            _loc4_ = new Color(this.Indicator.Frame.Outline);
            _loc4_.setRGB(this.outlineColor);
         default:
            return;
      }
   }
   function addDamage(a_damage)
   {
      this.damage += a_damage;
      this.DamageCounter.text = this.damage.toString();
      this.damageTimeline.restart();
      this.updateDamageY();
   }
   function resetDamage()
   {
      this.damage = 0;
   }
   function isHidden()
   {
      return this.bHidden;
   }
   function isReadyToRemove()
   {
      return this.bReadyToRemove;
   }
   function setColors(a_uHealthColor, a_uHealthPhantomColor, a_uHealthBackgroundColor, a_uHealthPenaltyColor, a_uHealthFlashColor, a_uMagickaColor, a_uMagickaPhantomColor, a_uMagickaBackgroundColor, a_uMagickaPenaltyColor, a_uMagickaFlashColor, a_uStaminaColor, a_uStaminaPhantomColor, a_uStaminaBackgroundColor, a_uStaminaPenaltyColor, a_uStaminaFlashColor, a_uSpecialColor, a_uSpecialPhantomColor, a_uSpecialBackgroundColor, a_uSpecialPenaltyColor, a_uSpecialFlashColor)
   {
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
      this.Bars.HealthBar.setColor(this.uHealthColor,this.uHealthPhantomColor,this.uHealthBackgroundColor,this.uHealthPenaltyColor,this.uHealthFlashColor);
      this.Bars.Resources.MagickaBar.setColor(this.uMagickaColor,this.uMagickaPhantomColor,this.uMagickaBackgroundColor,this.uMagickaPenaltyColor,this.uMagickaFlashColor);
      this.Bars.Resources.StaminaBar.setColor(this.uStaminaColor,this.uStaminaPhantomColor,this.uStaminaBackgroundColor,this.uStaminaPenaltyColor,this.uStaminaFlashColor);
      this.Bars.Special.SpecialBar.setColor(this.uSpecialColor,this.uSpecialPhantomColor,this.uSpecialBackgroundColor,this.uSpecialPenaltyColor,this.uSpecialFlashColor);
   }
   function setWidth(a_width, a_resourceWidth)
   {
      this.fCurrentWidth = a_width;
      this.fCurrentResourceWidth = a_resourceWidth;
      this.Bars.HealthBar.setWidth(a_width);
      this.Bars.Resources.MagickaBar.setWidth(a_resourceWidth + this.magickaWidthOffset);
      this.Bars.Resources.StaminaBar.setWidth(a_resourceWidth);
      this.Bars.Special.SpecialBar.setWidth(a_resourceWidth);
      this.Bars.ResourceMask._width = a_resourceWidth + this.resourcesFrameWidthOffset;
      this.Bars.Resources.Frame._width = a_resourceWidth + this.resourcesFrameWidthOffset;
      this.Bars.Resources.Outline._width = a_resourceWidth + this.resourcesFrameOutlineWidthOffset;
      this.Bars.Special.Frame._width = a_resourceWidth + this.specialFrameWidthOffset;
      this.Bars.Special.Outline._width = a_resourceWidth + this.specialFrameOutlineWidthOffset;
      var _loc3_ = a_width + this.healthXOffset;
      this.DamageCounter._width = _loc3_;
      this.DamageCounter._x = (- _loc3_) / 2;
      this.updateNameY();
      this.updateDamageY();
   }
}
