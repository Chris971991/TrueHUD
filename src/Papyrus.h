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

	void Register();
}
