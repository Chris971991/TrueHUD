#include "Widgets/ActorInfoBar.h"
#include "Offsets.h"
#include "Settings.h"
#include "Utils.h"
#include "HUDHandler.h"
#include "Scaleform/Scaleform.h"

namespace Scaleform
{
	void ActorInfoBar::Update(float a_deltaTime)
	{
		RE::GFxValue result;
		_object.Invoke("isReadyToRemove", &result);
		if (result.GetBool()) {
			_widgetState = WidgetState::kRemoved;
			return;
		}

		_bHiddenByRangeOrSight = IsOutOfRangeOrSight(a_deltaTime);
		if (_bHiddenByRangeOrSight) {
			// Hidden, not removed: it shows again once back in range and sight, while TrueHUD still wants it
			RE::GFxValue::DisplayInfo displayInfo;
			displayInfo.SetVisible(false);
			_object.SetDisplayInfo(displayInfo);
		} else {
			UpdatePosition();
		}

		// Dovakarn: a hidden bar's state runs on too (it used to stop above). One TrueHUD no longer wants (combat over, the
		// keep time after a hit run out, its actor dead) fades and is removed unseen, instead of waiting hidden until its
		// actor next comes into range and sight and then flashing up only to fade out. UpdateInfo hides it the way it
		// hides a bar off screen (_bHiddenByRangeOrSight), so the movie and this side agree and it fades in when it is back.
		// The keep time after the last hit between this actor and the player runs down first, shown or hidden: after the
		// range check above, so the bar is still drawn on the frame the time runs out and its fade is seen, and by at most
		// a quarter of a second a frame, so a stall (a loading screen, the menu's first frame) does not use it up
		if (_fightTimeLeft > 0.f) {
			const float step = a_deltaTime < 0.25f ? a_deltaTime : 0.25f;
			if (step > 0.f) {
				_fightTimeLeft = step < _fightTimeLeft ? _fightTimeLeft - step : 0.f;
			}
		}

		UpdateInfo();
	}

	bool ActorInfoBar::IsOutOfRangeOrSight(float a_deltaTime)
	{
		// Dovakarn: a bar that is already leaving stays as it was, shown or hidden, to the end. The movie's leaving fade
		// starts from full strength, so a hidden one coming into view part way through it would flash; a shown one is
		// seen out
		if (_widgetState >= WidgetState::kDelayedRemoval) {
			return _bHiddenByRangeOrSight;
		}

#ifdef DOVAKARN_DEV
		_hideReason = kNotHidden;
#endif

		if (Settings::fInfoBarMaxDistance <= 0.f && !Settings::bInfoBarRequireLineOfSight) {
			return false;
		}

		auto playerCharacter = RE::PlayerCharacter::GetSingleton();
		auto target = _refHandle.get();
		if (!playerCharacter || !target) {
			return false;
		}

		// Dovakarn: an actor in a fight with the player (one hit the other within the keep time) shows further out
		const float maxDistance = IsInFight() && Settings::fInfoBarFightMaxDistance > Settings::fInfoBarMaxDistance ? Settings::fInfoBarFightMaxDistance : Settings::fInfoBarMaxDistance;
		if (Settings::fInfoBarMaxDistance > 0.f && playerCharacter->GetPosition().GetDistance(target->GetPosition()) > maxDistance) {
#ifdef DOVAKARN_DEV
			_hideReason = kOutOfRange;
#endif
			return true;
		}

		if (Settings::bInfoBarRequireLineOfSight) {
			// Asked at most every 0.12 s per bar; the last answer stands in between
			_timeSinceLineOfSightCheck += a_deltaTime;
			if (!_bLineOfSightChecked || _timeSinceLineOfSightCheck >= 0.12f) {
				bool bUnk = false;
				_bHasLineOfSight = playerCharacter->HasLineOfSight(target.get(), bUnk);
				_bLineOfSightChecked = true;
				_timeSinceLineOfSightCheck = 0.f;
			}
#ifdef DOVAKARN_DEV
			if (!_bHasLineOfSight) {
				_hideReason = kOutOfSight;
			}
#endif
			return !_bHasLineOfSight;
		}

		return false;
	}

	void ActorInfoBar::UpdatePosition()
	{
		if (!_refHandle) {
			_widgetState = WidgetState::kRemoved;
			return;
		}

		// don't update position if alpha is zero
		/*RE::GFxValue::DisplayInfo dInfo;
		object.GetDisplayInfo(&dInfo);
		if (dInfo.GetAlpha() == 0) {
			return;
		}*/

		/*RE::GFxValue alpha;
		object.GetMember("_alpha", &alpha);
		if (alpha.GetNumber() == 0) {
			return;
		}*/

		RE::GRectF rect = _view->GetVisibleFrameRect();

		RE::NiPoint3 targetPos;
		bool bPlaced = false;
		if (Settings::uInfoBarAnchor == WidgetAnchor::kHeadNode) {
			auto target = _refHandle.get();
			if (target && target->formType == RE::FormType::ActorCharacter && target->Get3D2()) {
				bPlaced = Utils::GetNodePosition(RE::ActorPtr(target->As<RE::Actor>()), "NPC Head [Head]", targetPos);
			}
		}
		if (!bPlaced && !Utils::GetTargetPos(_refHandle, targetPos, Settings::uInfoBarAnchor == WidgetAnchor::kBody)) {
			// Dovakarn: the actor has no 3D loaded (or the reference is gone), so there is no point to draw the bar at.
			// TrueHUD went on with an unset position, which drew the bar at the world's origin. Not drawn, and counted as
			// off screen, so UpdateInfo hides it and it fades in once there is a point again
			_bIsOffscreen = true;
			RE::GFxValue::DisplayInfo displayInfo;
			displayInfo.SetVisible(false);
			_object.SetDisplayInfo(displayInfo);
			return;
		}
		targetPos.z += Settings::fInfoBarOffsetZ;
		RE::NiPoint2 screenPos;

		RE::NiCamera::WorldPtToScreenPt3((float(*)[4])g_worldToCamMatrix, *g_viewPort, targetPos, screenPos.x, screenPos.y, _depth, 1e-5f);

		_bIsOffscreen = _depth < 0;

		if (_bIsOffscreen) {
			RE::GFxValue alpha;
			_object.GetMember("_alpha", &alpha);
			if (alpha.GetNumber() == 0) {
				return;
			}
		}

		float fNear = *g_fNear;
		float fFar = *g_fFar;
		float linearizedDepth = fNear * fFar / (fFar + _depth * (fNear - fFar));

		screenPos.y = 1.0f - screenPos.y;  // Flip y for Flash coordinate system
		screenPos.y = rect.top + (rect.bottom - rect.top) * screenPos.y;
		screenPos.x = rect.left + (rect.right - rect.left) * screenPos.x;

		float scale;

		if (Settings::bInfoBarScaleWithDistance) {
			float scaleMult = fmin(fmax(linearizedDepth, 500.f), 2000.f);
			float remapped = (((scaleMult - 500.f) * (50.f - 100.f)) / (2000.f - 500.f)) + 100.f;
			scale = remapped;
		} else {
			scale = 100.f;
		}

		scale *= Settings::fInfoBarScale;

		RE::GFxValue::DisplayInfo displayInfo;
		displayInfo.SetPosition(screenPos.x, screenPos.y);
		displayInfo.SetScale(scale, scale);
		displayInfo.SetVisible(true);
		_object.SetDisplayInfo(displayInfo);
	}

	void ActorInfoBar::LoadConfig()
	{
		using ColorType = TRUEHUD_API::BarColorType;

		auto hudHandler = HUDHandler::GetSingleton();
		auto hudMenu = HUDHandler::GetTrueHUDMenu();

		RE::GFxValue args[44];
		args[0].SetNumber(static_cast<uint32_t>(Settings::uInfoBarDirection));
		args[1].SetNumber(static_cast<uint32_t>(Settings::uInfoBarDisplayName));
		args[2].SetBoolean(Settings::bInfoBarDisplayPhantomBars);
		args[3].SetBoolean(Settings::bInfoBarDisplaySpecialPhantomBar);
		args[4].SetNumber(static_cast<uint32_t>(Settings::uInfoBarDisplayDamageCounter));
		args[5].SetNumber(static_cast<uint32_t>(Settings::uInfoBarDisplayIndicator));
		args[6].SetNumber(static_cast<uint32_t>(Settings::uInfoBarDamageCounterAlignment));
		args[7].SetNumber(static_cast<uint32_t>(Settings::uInfoBarResourcesModeTarget));
		args[8].SetNumber(static_cast<uint32_t>(Settings::uInfoBarResourcesModeHostiles));
		args[9].SetNumber(static_cast<uint32_t>(Settings::uInfoBarResourcesModeTeammates));
		args[10].SetNumber(static_cast<uint32_t>(Settings::uInfoBarResourcesModeOthers));
		args[11].SetNumber(static_cast<uint32_t>(Settings::uInfoBarSpecialModeTarget));
		args[12].SetNumber(static_cast<uint32_t>(Settings::uInfoBarSpecialModeHostiles));
		args[13].SetNumber(static_cast<uint32_t>(Settings::uInfoBarSpecialModeTeammates));
		args[14].SetNumber(static_cast<uint32_t>(Settings::uInfoBarSpecialModeOthers));
		args[15].SetBoolean(hudHandler->bSpecialMode);
		args[16].SetNumber(static_cast<uint32_t>(Settings::uInfoBarIndicatorMode));	
		args[17].SetNumber(Settings::fInfoBarPhantomDuration);
		args[18].SetNumber(Settings::fInfoBarDamageCounterDuration);
		args[19].SetNumber((Settings::bInfoBarUseHUDOpacity ? *g_fHUDOpacity : Settings::fInfoBarOpacity) * 100.f);
		args[20].SetNumber(Settings::fInfoBarWidth);
		args[21].SetNumber(Settings::fInfoBarResourceWidth);
		args[22].SetNumber(Settings::fInfoBarTargetWidth);
		args[23].SetNumber(Settings::fInfoBarTargetResourceWidth);
		args[24].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kHealth, ColorType::BarColor));
		args[25].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kHealth, ColorType::PhantomColor));
		args[26].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kHealth, ColorType::BackgroundColor));
		args[27].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kHealth, ColorType::PenaltyColor));
		args[28].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kHealth, ColorType::FlashColor));
		args[29].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kMagicka, ColorType::BarColor));
		args[30].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kMagicka, ColorType::PhantomColor));
		args[31].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kMagicka, ColorType::BackgroundColor));
		args[32].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kMagicka, ColorType::PenaltyColor));
		args[33].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kMagicka, ColorType::FlashColor));
		args[34].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kStamina, ColorType::BarColor));
		args[35].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kStamina, ColorType::PhantomColor));
		args[36].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kStamina, ColorType::BackgroundColor));
		args[37].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kStamina, ColorType::PenaltyColor));
		args[38].SetNumber(hudMenu->GetBarColor(_refHandle, RE::ActorValue::kStamina, ColorType::FlashColor));
		args[39].SetNumber(hudMenu->GetSpecialBarColor(_refHandle, ColorType::BarColor));
		args[40].SetNumber(hudMenu->GetSpecialBarColor(_refHandle, ColorType::PhantomColor));
		args[41].SetNumber(hudMenu->GetSpecialBarColor(_refHandle, ColorType::BackgroundColor));
		args[42].SetNumber(hudMenu->GetSpecialBarColor(_refHandle, ColorType::PenaltyColor));
		args[43].SetNumber(hudMenu->GetSpecialBarColor(_refHandle, ColorType::FlashColor));
		_object.Invoke("loadConfig", nullptr, args, 44);
	}
}
