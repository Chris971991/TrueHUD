Scriptname DovakarnBars Hidden
{Dovakarn's TrueHUD build (health bars in a fight): src/Papyrus.cpp DovakarnBars}

; The game server says akActor is in a fight with the player that this game raised no hit for (another player's hit on
; the player, the player's heal on someone, another player's hit on an NPC near the player): its floating health bar is
; added or kept for fInfoBarFightKeepTime, as after a hit between the player and akActor.
Function Fight(Actor akActor) global native

; The lower bars akActor really has, which its floating bar shows: 1 magicka + 2 stamina (3 for none given). Stamina when
; its maximum is above 0; magicka when its maximum is above 0 and it is a person (the player, a playable or face-generated
; race) or knows a spell that costs magicka. Dovakarn's client asks it so the name plate lifts by the bars shown.
Int Function Pools(Actor akActor) global native
