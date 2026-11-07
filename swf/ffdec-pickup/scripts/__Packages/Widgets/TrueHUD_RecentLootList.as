class Widgets.TrueHUD_RecentLootList extends MovieClip
{
   var currentMessageArray;
   var fRecentLootMessageDuration;
   var fRecentLootOpacity;
   var uRecentLootListDirection;
   var uRecentLootMaxMessageCount;
   var unusedMessageArray;
   var messageCount = 0;
   var yOffset = 34;
   function TrueHUD_RecentLootList()
   {
      super();
      this.stop();
      this.currentMessageArray = new Array();
      this.unusedMessageArray = new Array();
   }
   function init()
   {
      this.cleanUp();
      this._alpha = this.fRecentLootOpacity;
   }
   function cleanUp()
   {
      var _loc2_ = 0;
      while(_loc2_ < this.currentMessageArray.length)
      {
         this.currentMessageArray[_loc2_].cleanUp();
         delete this.currentMessageArray[_loc2_];
         _loc2_ = _loc2_ + 1;
      }
      this.currentMessageArray.splice(0);
      _loc2_ = 0;
      while(_loc2_ < this.unusedMessageArray.length)
      {
         this.unusedMessageArray[_loc2_].cleanUp();
         delete this.unusedMessageArray[_loc2_];
         _loc2_ = _loc2_ + 1;
      }
      this.unusedMessageArray.splice(0);
   }
   function loadConfig(a_uRecentLootMaxMessageCount, a_fRecentLootMessageDuration, a_fRecentLootOpacity, a_uRecentLootListDirection)
   {
      this.uRecentLootMaxMessageCount = a_uRecentLootMaxMessageCount;
      this.fRecentLootMessageDuration = a_fRecentLootMessageDuration;
      this.fRecentLootOpacity = a_fRecentLootOpacity;
      this.uRecentLootListDirection = a_uRecentLootListDirection;
      this.init();
   }
   function addMessage(a_itemName, a_itemCount, a_iconLabel, a_iconColor)
   {
      if(this.currentMessageArray.length > 0)
      {
         if(this.currentMessageArray[0].itemName == a_itemName && this.currentMessageArray[0].isJustAdded())
         {
            this.currentMessageArray[0].addCount(a_itemCount);
            return undefined;
         }
      }
      var _loc5_ = 0;
      var _loc6_;
      while(_loc5_ < this.currentMessageArray.length)
      {
         _loc6_ = this.currentMessageArray[_loc5_];
         if(_loc6_.itemName == a_itemName && _loc6_.isShowing())
         {
            _loc6_.addCount(a_itemCount);
            _loc6_.refresh();
            if(_loc5_ > 0)
            {
               this.currentMessageArray.splice(_loc5_,1);
               this.currentMessageArray.unshift(_loc6_);
               this.updatePositions();
            }
            return undefined;
         }
         _loc5_ = _loc5_ + 1;
      }
      var _loc3_;
      if(this.unusedMessageArray.length == 0)
      {
         if(this.currentMessageArray.length > this.uRecentLootMaxMessageCount)
         {
            return undefined;
         }
         _loc3_ = this.attachMovie("TrueHUD_RecentLootEntry","LootMessage" + this.messageCount++,this.getNextHighestDepth());
         _loc3_.loadConfig(this.fRecentLootMessageDuration);
         this.unusedMessageArray.push(_loc3_);
      }
      var _loc2_ = this.unusedMessageArray.pop();
      var _loc4_ = this.currentMessageArray.length == 0;
      _loc2_.addMessage(a_itemName,a_itemCount,a_iconLabel,a_iconColor,_loc4_);
      this.currentMessageArray.unshift(_loc2_);
      this.updatePositions();
      if(this.currentMessageArray.length > this.uRecentLootMaxMessageCount)
      {
         this.currentMessageArray[this.currentMessageArray.length - 1].hideMessage();
      }
   }
   function updatePositions()
   {
      var _loc4_ = this.uRecentLootListDirection != 0 ? 1 : -1;
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.currentMessageArray.length)
      {
         _loc3_ = this.currentMessageArray[_loc2_];
         _loc3_.setY(this.yOffset * _loc4_ * _loc2_);
         _loc2_ = _loc2_ + 1;
      }
   }
   function update()
   {
      var _loc4_ = false;
      var _loc2_ = 0;
      var _loc3_;
      while(_loc2_ < this.currentMessageArray.length)
      {
         _loc3_ = this.currentMessageArray[_loc2_];
         if(_loc3_.isReadyToRemove())
         {
            this.currentMessageArray.splice(_loc2_--,1);
            this.unusedMessageArray.push(_loc3_);
            _loc4_ = true;
         }
         _loc2_ = _loc2_ + 1;
      }
      if(_loc4_)
      {
         this.updatePositions();
      }
   }
}
