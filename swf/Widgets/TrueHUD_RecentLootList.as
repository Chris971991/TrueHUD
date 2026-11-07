import TrueHUD_RecentLootEntry;

class Widgets.TrueHUD_RecentLootList extends MovieClip
{
	private var currentMessageArray: Array;
	private var unusedMessageArray: Array;

	var uRecentLootMaxMessageCount: Number;
	var fRecentLootMessageDuration: Number;
	var fRecentLootOpacity: Number;
	var uRecentLootListDirection: Number;

	var messageCount = 0;

	// Dovakarn: rows 40 of Dovakarn's HUD units apart, at the entries' UI scale (TrueHUD_RecentLootEntry.scaleNow)
	var yOffset = 40;
	var lootScale = 0;

	public function TrueHUD_RecentLootList() 
	{
		// constructor code
		this.stop();

		currentMessageArray = new Array();
		unusedMessageArray = new Array();
	}

	public function init()
	{
		cleanUp();

		this._alpha = fRecentLootOpacity;
	}
	
	public function cleanUp()
	{
		for (var i:Number = 0; i < currentMessageArray.length; i++)
		{
			currentMessageArray[i].cleanUp();
			delete currentMessageArray[i];
		}

		currentMessageArray.splice(0);

		for (var i:Number = 0; i < unusedMessageArray.length; i++)
		{
			unusedMessageArray[i].cleanUp();
			delete unusedMessageArray[i];
		}

		unusedMessageArray.splice(0);
	}

	public function loadConfig(a_uRecentLootMaxMessageCount:Number,
		a_fRecentLootMessageDuration: Number,
		a_fRecentLootOpacity: Number,
		a_uRecentLootListDirection: Number)
	{
		uRecentLootMaxMessageCount = a_uRecentLootMaxMessageCount;
		fRecentLootMessageDuration = a_fRecentLootMessageDuration;
		fRecentLootOpacity = a_fRecentLootOpacity;
		uRecentLootListDirection = a_uRecentLootListDirection;

		init();
	}

	public function addMessage(a_itemName: String, a_itemCount: Number, a_iconLabel: String, a_iconColor: Number)
	{
		if (currentMessageArray.length > 0)
		{
			if (currentMessageArray[0].itemName == a_itemName && currentMessageArray[0].isJustAdded())
			{
				currentMessageArray[0].addCount(a_itemCount);
				return;
			}
		}

		// Dovakarn: the same item arriving again while its line still shows adds to that line ("Gold (3)" then 2 more is
		// "Gold (5)"), which moves to the top and shows its full time again. TrueHUD itself merged only adds made in the
		// same frame (isJustAdded)
		for (var j:Number = 0; j < currentMessageArray.length; j++)
		{
			var shown = currentMessageArray[j];
			if (shown.itemName == a_itemName && shown.isShowing())
			{
				shown.addCount(a_itemCount);
				shown.refresh();
				if (j > 0)
				{
					currentMessageArray.splice(j, 1);
					currentMessageArray.unshift(shown);
					updatePositions();
				}
				return;
			}
		}

		if (unusedMessageArray.length == 0)
		{
			if (currentMessageArray.length > uRecentLootMaxMessageCount)
			{
				return;
			}

			// Add a new movieclip
			var newClip = attachMovie("TrueHUD_RecentLootEntry", "LootMessage" + messageCount++, this.getNextHighestDepth());
			newClip.loadConfig(fRecentLootMessageDuration);
			unusedMessageArray.push(newClip);
			//trace("added new message mc");
		}
		var messageClip = unusedMessageArray.pop();
		var bInstant = currentMessageArray.length == 0;
		messageClip.addMessage(a_itemName, a_itemCount, a_iconLabel, a_iconColor, bInstant);
		currentMessageArray.unshift(messageClip);
		updatePositions();

		if (currentMessageArray.length > uRecentLootMaxMessageCount)
		{
			currentMessageArray[currentMessageArray.length - 1].hideMessage();
		}
	}

	public function updatePositions()
	{
		var direction = uRecentLootListDirection == 0 ? -1 : 1;
		for (var i:Number = 0; i < currentMessageArray.length; i++) 
		{
			var entry = currentMessageArray[i];
			entry.setY(yOffset * scaleNow() * direction * i);
		}
	}

	private function scaleNow(): Number
	{
		if (lootScale <= 0)
		{
			lootScale = TrueHUD_RecentLootEntry.scaleNow();
		}
		return lootScale;
	}

	public function update()
	{
		// Dovakarn: the player's UI scale (or the screen) moved: every line takes it, and the rows close up again
		var s: Number = TrueHUD_RecentLootEntry.scaleNow();
		if (s != lootScale)
		{
			lootScale = s;
			for (var k: Number = 0; k < currentMessageArray.length; k++)
			{
				currentMessageArray[k].applyScale(s);
			}
			for (var u: Number = 0; u < unusedMessageArray.length; u++)
			{
				unusedMessageArray[u].applyScale(s);
			}
			updatePositions();
		}
		var bShouldUpdatePositions = false;
		for (var i:Number = 0; i < currentMessageArray.length; i++) 
		{
			var entry = currentMessageArray[i];
			if (entry.isReadyToRemove())
			{
				currentMessageArray.splice(i--, 1);
				unusedMessageArray.push(entry);
				bShouldUpdatePositions = true;
			}
		}

		if (bShouldUpdatePositions)
		{
			updatePositions();
		}
	}
}
