#include "Papyrus.h"

#include "Settings.h"
#include "HUDHandler.h"

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

	void Register()
	{
		auto papyrus = SKSE::GetPapyrusInterface();
		papyrus->Register(TrueHUD_MCM::Register);
		papyrus->Register(DovakarnLoot::Register);
		logger::info("Registered papyrus functions");
	}
}
