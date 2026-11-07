Scriptname DovakarnLoot Hidden
{Dovakarn's TrueHUD build (Recent Loot): src/Papyrus.cpp DovakarnLoot}

; No Recent Loot line for the next afSeconds (0 ends the quiet at once). Dovakarn's client calls it while it puts the
; server's saved pack back into the player's inventory (login, a load, a character switch, a correcting pass), so only
; real arrivals are listed.
Function Quiet(float afSeconds) global native
