#pragma once
#include "Widgets/InfoBarBase.h"

namespace Scaleform
{
	class ActorInfoBar : public InfoBarBase
	{
	public:
		ActorInfoBar(RE::GPtr<RE::GFxMovieView> a_view, RE::ObjectRefHandle a_refHandle) :
			InfoBarBase(a_view, a_refHandle)
		{
			_barType = InfoBarBase::kActorInfoBar;
		}

		virtual void Update(float a_deltaTime) override;

	protected:
		virtual void UpdatePosition() override;
		virtual void LoadConfig() override;

		// Whether the bar is hidden for range or sight (fInfoBarMaxDistance, bInfoBarRequireLineOfSight); the widget stays
		bool IsOutOfRangeOrSight(float a_deltaTime);

		float _timeSinceLineOfSightCheck = 0.f;
		bool _bHasLineOfSight = true;
		bool _bLineOfSightChecked = false;
	};
}
