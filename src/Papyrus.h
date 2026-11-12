#pragma once

namespace Papyrus
{
	class TrueHUD_MCM
	{
	public:
		static void OnConfigClose(RE::TESQuest*);

		static bool Register(RE::BSScript::IVirtualMachine* a_vm);
	};

	// Dovakarn: Scriptname DovakarnLoot Hidden / Function Quiet(float afSeconds) global native (scripts/source/DovakarnLoot.psc)
	class DovakarnLoot
	{
	public:
		static void Quiet(RE::StaticFunctionTag*, float a_seconds);

		static bool Register(RE::BSScript::IVirtualMachine* a_vm);
	};

	// Dovakarn: Scriptname DovakarnBars Hidden / Function Fight(Actor akActor) global native (scripts/source/DovakarnBars.psc).
	// The game server's word that this actor is in a fight with the player that this game raises no hit event for: another
	// player's hit on the player (their copy's spell or swing never hits here), the player's heal on someone (the game's own
	// gate refuses the caster's effect on another actor, the server lands it), another player's hit on an NPC near the player.
	// The bar is added or kept for fInfoBarFightKeepTime, as a hit between the player and that actor does
	class DovakarnBars
	{
	public:
		static void Fight(RE::StaticFunctionTag*, RE::Actor* a_actor);

		static bool Register(RE::BSScript::IVirtualMachine* a_vm);
	};

	void Register();
}
