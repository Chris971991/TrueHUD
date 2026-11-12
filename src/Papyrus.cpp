#include "Papyrus.h"

#include "Settings.h"
#include "HUDHandler.h"
#include "Utils.h"

namespace Papyrus
{
	void TrueHUD_MCM::OnConfigClose(RE::TESQuest*)
	{
		Settings::ReadSettings();
	}

	bool TrueHUD_MCM::Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("OnConfigClose", "TrueHUD_MCM", OnConfigClose);

		logger::info("Registered TrueHUD_MCM class");
		return true;
	}

	void DovakarnLoot::Quiet(RE::StaticFunctionTag*, float a_seconds)
	{
		HUDHandler::GetSingleton()->QuietRecentLoot(a_seconds);
	}

	bool DovakarnLoot::Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("Quiet", "DovakarnLoot", Quiet);

		logger::info("Registered DovakarnLoot class");
		return true;
	}

	void DovakarnBars::Fight(RE::StaticFunctionTag*, RE::Actor* a_actor)
	{
		auto playerCharacter = RE::PlayerCharacter::GetSingleton();
		if (!a_actor || !playerCharacter || a_actor->IsPlayerRef() || Settings::fInfoBarFightKeepTime <= 0.f) {
			return;
		}
		// The kinds of bar the settings show at all, as the hit handler asks them
		bool bShowsBars = false;
		if (a_actor->IsHostileToActor(playerCharacter)) {
			bShowsBars = Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kNever;
		} else if (Utils::IsPlayerTeammateOrSummon(a_actor)) {
			bShowsBars = Settings::uInfoBarDisplayTeammates > InfoBarsDisplayMode::kNever;
		} else {
			bShowsBars = Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kNever;
		}
		if (bShowsBars) {
			HUDHandler::GetSingleton()->NoteActorFight(a_actor->GetHandle());
		}
	}

	bool DovakarnBars::Register(RE::BSScript::IVirtualMachine* a_vm)
	{
		a_vm->RegisterFunction("Fight", "DovakarnBars", Fight);

		logger::info("Registered DovakarnBars class");
		return true;
	}

	void Register()
	{
		auto papyrus = SKSE::GetPapyrusInterface();
		papyrus->Register(TrueHUD_MCM::Register);
		papyrus->Register(DovakarnLoot::Register);
		papyrus->Register(DovakarnBars::Register);
		logger::info("Registered papyrus functions");
	}
}
