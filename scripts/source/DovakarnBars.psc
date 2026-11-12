Scriptname DovakarnBars Hidden
{Dovakarn's TrueHUD build (health bars in a fight): src/Papyrus.cpp DovakarnBars}

; The game server says akActor is in a fight with the player that this game raised no hit for (another player's hit on
; the player, the player's heal on someone, another player's hit on an NPC near the player): its floating health bar is
; added or kept for fInfoBarFightKeepTime, as after a hit between the player and akActor.
Function Fight(Actor akActor) global native
