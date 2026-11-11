#pragma once
#include "TrueHUDAPI.h"

namespace Scaleform
{
	class InfoBarBase : public TRUEHUD_API::WidgetBase
	{
	public:
		enum TargetType : std::uint8_t
		{
			kTarget = 0,
			kEnemy = 1,
			kTeammate = 2,
			kOther = 3,
		};

		enum TargetState : std::uint8_t
		{
			kAlive = 0,
			kStunned = 1,
			kBleedingOut = 2,
			kBleedingOutEssential = 3,
			kDead = 4
		};

		enum WidgetStateMode : std::uint8_t
		{
			kAdd = 0,
			kShow = 1,
			kHide = 2,
			kRemove = 3,
			kTargetKilled = 4
		};

		enum BarType : std::uint8_t
		{
			kActorInfoBar = 0,
			kBossInfoBar = 1
		};

		InfoBarBase(RE::GPtr<RE::GFxMovieView> a_view, RE::ObjectRefHandle a_refHandle) :
			WidgetBase(a_view, a_refHandle.native_handle()),
			_refHandle(a_refHandle)
		{}

		virtual void Initialize() override;
		virtual void Dispose() override;

		virtual void SetWidgetState(WidgetStateMode a_state);
		virtual void FlashActorValue(RE::ActorValue a_actorValue, bool a_bLong);
		virtual void FlashSpecial(bool a_bLong);
		virtual void RefreshColors();

		RE::ObjectRefHandle _refHandle;

		// Dovakarn: the player hit this actor or was hit by it. For fInfoBarFightKeepTime seconds from now its bar stays
		// whether or not the game counts the actor as in combat (UpdateInfo), and shows out to fInfoBarFightMaxDistance
		// (ActorInfoBar). Called and read only on the thread that runs the menu (TrueHUDMenu::AdvanceMovie): the hit event
		// reaches it as a HUD task (HUDHandler::NoteActorFight), so it needs no lock of its own
		void NoteFight();
		bool IsInFight() const { return _fightTimeLeft > 0.f; }

#ifdef DOVAKARN_DEV
		// Dovakarn, dev build only, for the read-back (_root.dovBars) and the bar log: why the bar is hidden by range or
		// sight (ActorInfoBar), what TrueHUD last took the actor for, its health as last handed to the movie, and the line
		// last logged for it
		enum HideReason : std::uint8_t
		{
			kNotHidden = 0,
			kOutOfRange = 1,
			kOutOfSight = 2
		};
		HideReason _hideReason = kNotHidden;
		TargetType _targetType = kOther;
		float _healthPct = -1.f;
		std::string _lastLogged;
		bool IsOffscreen() const { return _bIsOffscreen; }
#endif

	protected:
		virtual void UpdatePosition() = 0;
		virtual void LoadConfig() = 0;

		virtual void UpdateInfo();

		bool _bIsOffscreen = false;
		// Dovakarn: set by ActorInfoBar while its range or sight rule hides the bar. UpdateInfo then treats the bar as it
		// treats one off screen (hidden, and it fades in when it is back), and still decides whether it leaves
		bool _bHiddenByRangeOrSight = false;

		BarType _barType;

		// Dovakarn: seconds left of the keep time since the last hit between this actor and the player (0: none). Run down by
		// ActorInfoBar::Update, set again by NoteFight
		float _fightTimeLeft = 0.f;
		// Dovakarn: the lowest health seen since the keep time was last set (below 0: not looked at yet). Damage over time
		// raises no hit event for its ticks; health falling below this counts as a hit landing (UpdateInfo)
		float _fightLowHealth = -1.f;
	};
}
