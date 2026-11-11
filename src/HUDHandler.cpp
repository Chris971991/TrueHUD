#include "HUDHandler.h"

#include "Offsets.h"
#include "Settings.h"
#include "Utils.h"

void HUDHandler::Register()
{
	auto scriptEventSourceHolder = RE::ScriptEventSourceHolder::GetSingleton();
	scriptEventSourceHolder->GetEventSource<RE::TESCombatEvent>()->AddEventSink(HUDHandler::GetSingleton());
	logger::info("Registered {}"sv, typeid(RE::TESCombatEvent).name());
	scriptEventSourceHolder->GetEventSource<RE::TESDeathEvent>()->AddEventSink(HUDHandler::GetSingleton());
	logger::info("Registered {}"sv, typeid(RE::TESDeathEvent).name());
	scriptEventSourceHolder->GetEventSource<RE::TESEnterBleedoutEvent>()->AddEventSink(HUDHandler::GetSingleton());
	logger::info("Registered {}"sv, typeid(RE::TESEnterBleedoutEvent).name());
	scriptEventSourceHolder->GetEventSource<RE::TESHitEvent>()->AddEventSink(HUDHandler::GetSingleton());
	logger::info("Registered {}"sv, typeid(RE::TESHitEvent).name());
	auto ui = RE::UI::GetSingleton();
	ui->AddEventSink<RE::MenuOpenCloseEvent>(HUDHandler::GetSingleton());
	logger::info("Registered {}"sv, typeid(RE::MenuOpenCloseEvent).name());
}

// On combat start, add info/boss bar; on combat end, remove bar
HUDHandler::EventResult HUDHandler::ProcessEvent(const RE::TESCombatEvent* a_event, RE::BSTEventSource<RE::TESCombatEvent>*)
{
	using WidgetRemovalMode = TRUEHUD_API::WidgetRemovalMode;

	bool bInfoBarsEnabled = Settings::bEnableActorInfoBars && 
							(Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kNever ||
								Settings::uInfoBarDisplayTeammates > InfoBarsDisplayMode::kNever ||
								Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kNever);

	if (bInfoBarsEnabled || Settings::bEnableBossBars) {
		using CombatState = RE::ACTOR_COMBAT_STATE;

		const auto isPlayerRef = [](auto&& a_ref) {
			return a_ref && a_ref->IsPlayerRef();
		};

		auto eventActor = a_event->actor;
		auto eventTarget = a_event->targetActor;

		if (a_event && eventActor && eventTarget) {
			bool bIsRelevant = eventTarget->IsPlayerRef();
			if (!bIsRelevant && bInfoBarsEnabled) {
				auto actor = eventActor->As<RE::Actor>();
				if (Utils::IsPlayerTeammateOrSummon(actor)) {
					bIsRelevant = true;
				}
			}

#ifdef DOVAKARN_DEV
			if (Settings::bInfoBarLog && (bIsRelevant || eventActor->IsPlayerRef())) {
				auto actor = eventActor->As<RE::Actor>();
				logger::info("combat event: [{}] state {} against [{}]; hostile to player {}, in combat {}, relevant {}", Utils::Describe(eventActor.get()), static_cast<uint32_t>(a_event->newState.get()), Utils::Describe(eventTarget.get()),
					actor ? actor->IsHostileToActor(RE::PlayerCharacter::GetSingleton()) : false, actor ? actor->IsInCombat() : false, bIsRelevant);
			}
#endif

			if (bIsRelevant) {
				auto actorHandle = eventActor->GetHandle();
				if (a_event->newState == CombatState::kCombat) {
					// Dovakarn: no menu (the HUD is closed), nothing to ask or add to; TrueHUD read through a null menu here
					auto trueHUDMenu = HUDHandler::GetTrueHUDMenu();
					if (!trueHUDMenu) {
						return EventResult::kContinue;
					}

					bool bHasBossBarAlready = trueHUDMenu->HasBossInfoBar(actorHandle);
					if (bHasBossBarAlready) {
						return EventResult::kContinue;
					}

					auto playerCharacter = RE::PlayerCharacter::GetSingleton();
					auto actor = eventActor->As<RE::Actor>();

					if (Settings::bEnableBossBars && CheckActorForBoss(actorHandle)) {  // Add a boss bar
						HUDHandler::GetSingleton()->AddBossInfoBar(actorHandle);
					} else if (bInfoBarsEnabled && actor && playerCharacter) {  // Not a boss, add a normal info bar
						if (actor->IsHostileToActor(playerCharacter)) {
							if (Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kOnHit) {
								HUDHandler::GetSingleton()->AddActorInfoBar(actorHandle);
							}
						} else if (Utils::IsPlayerTeammateOrSummon(actor)) {
							if (Settings::uInfoBarDisplayTeammates > InfoBarsDisplayMode::kOnHit) {
								HUDHandler::GetSingleton()->AddActorInfoBar(actorHandle);
							}
						} else if (Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kOnHit) {
							HUDHandler::GetSingleton()->AddActorInfoBar(actorHandle);
						}
					}

				} else if (a_event->newState == CombatState::kNone) {  // Combat end, remove bar
					if (Settings::bEnableBossBars) {
						HUDHandler::GetSingleton()->RemoveBossInfoBar(actorHandle, WidgetRemovalMode::Normal);
					}

					// Dovakarn: a bar a fight with the player still keeps (NoteActorFight) stays for its keep time
					if (bInfoBarsEnabled) {
						HUDHandler::GetSingleton()->RemoveActorInfoBarOnCombatEnd(actorHandle);
					}
				}
			}
		}
	}

	return EventResult::kContinue;
}

// On death, remove info/boss bar
HUDHandler::EventResult HUDHandler::ProcessEvent(const RE::TESDeathEvent* a_event, RE::BSTEventSource<RE::TESDeathEvent>*)
{
	using WidgetRemovalMode = TRUEHUD_API::WidgetRemovalMode;

	if (a_event && a_event->actorDying) {
		bool bInfoBarsEnabled = Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kNever ||
		                        Settings::uInfoBarDisplayTeammates > InfoBarsDisplayMode::kNever ||
		                        Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kNever;

		if (bInfoBarsEnabled || Settings::bEnableBossBars) {
			auto actorHandle = a_event->actorDying->GetHandle();
			if (Settings::bEnableBossBars) {
				HUDHandler::GetSingleton()->RemoveBossInfoBar(actorHandle, WidgetRemovalMode::Delayed);
			}

			if (bInfoBarsEnabled) {
				HUDHandler::GetSingleton()->RemoveActorInfoBar(actorHandle, WidgetRemovalMode::Delayed);
			}
		}
	}

	return EventResult::kContinue;
}

// On bleedout, for essential targets
HUDHandler::EventResult HUDHandler::ProcessEvent(const RE::TESEnterBleedoutEvent* a_event, RE::BSTEventSource<RE::TESEnterBleedoutEvent>*)
{
	using WidgetRemovalMode = TRUEHUD_API::WidgetRemovalMode;

	if (a_event && a_event->actor) {
		auto actor = a_event->actor->As<RE::Actor>();
		if (actor && actor->IsEssential()) {
			bool bInfoBarsEnabled = Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kNever ||
			                        Settings::uInfoBarDisplayTeammates > InfoBarsDisplayMode::kNever ||
			                        Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kNever;

			if (bInfoBarsEnabled || Settings::bEnableBossBars) {
				auto actorHandle = a_event->actor->GetHandle();
				if (Settings::bEnableBossBars) {
					HUDHandler::GetSingleton()->RemoveBossInfoBar(actorHandle, WidgetRemovalMode::Delayed);
				}

				if (bInfoBarsEnabled) {
					HUDHandler::GetSingleton()->RemoveActorInfoBar(actorHandle, WidgetRemovalMode::Delayed);
				}
			}
		}
	}

	return EventResult::kContinue;
}

// On hit, add info/boss bar
HUDHandler::EventResult HUDHandler::ProcessEvent(const RE::TESHitEvent* a_event, RE::BSTEventSource<RE::TESHitEvent>*)
{
	bool bInfoBarsEnabled = Settings::bEnableActorInfoBars &&
	                        (Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kNever ||
								Settings::uInfoBarDisplayTeammates > InfoBarsDisplayMode::kNever ||
								Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kNever);

	if (bInfoBarsEnabled || Settings::bEnableBossBars) {
		if (a_event && a_event->cause && a_event->target) {
			auto causeActorHandle = a_event->cause->GetHandle();
			auto targetActorHandle = a_event->target->GetHandle();

			if (causeActorHandle == targetActorHandle) {
				return EventResult::kContinue;
			}

			if (causeActorHandle && targetActorHandle) {
				auto causeActor = causeActorHandle.get()->As<RE::Actor>();
				auto targetActor = targetActorHandle.get()->As<RE::Actor>();

				if (causeActor && targetActor) {
					if (causeActor->IsDead() || targetActor->IsDead()) {
						return EventResult::kContinue;
					}

					bool bCausePlayer = causeActor->IsPlayerRef();
					bool bCausePlayerTeammate = Utils::IsPlayerTeammateOrSummon(causeActor);
					bool bTargetPlayer = targetActor->IsPlayerRef();
					bool bTargetPlayerTeammate = Utils::IsPlayerTeammateOrSummon(targetActor);

					if (!(bCausePlayer || bCausePlayerTeammate || bTargetPlayer || bTargetPlayerTeammate)) {
						return EventResult::kContinue;
					}

					// Dovakarn: no menu (the HUD is closed), nothing to ask or add to; TrueHUD read through a null menu here
					auto trueHUDMenu = HUDHandler::GetTrueHUDMenu();
					auto playerCharacter = RE::PlayerCharacter::GetSingleton();
					if (!trueHUDMenu || !playerCharacter) {
						return EventResult::kContinue;
					}

#ifdef DOVAKARN_DEV
					if (Settings::bInfoBarLog) {
						auto other = (bCausePlayer || bCausePlayerTeammate) ? targetActor : causeActor;
						logger::info("hit event: [{}] hit [{}] with {:08x}; the other one: hostile to player {}, in combat {}, {:.0f} units away, has a bar {}", Utils::Describe(causeActor), Utils::Describe(targetActor), a_event->source,
							other->IsHostileToActor(playerCharacter), other->IsInCombat(), playerCharacter->GetPosition().GetDistance(other->GetPosition()),
							trueHUDMenu->HasActorInfoBar(other == targetActor ? targetActorHandle : causeActorHandle));
					}
#endif

					// Dovakarn: TrueHUD adds a bar on a hit only for an actor the game counts as in combat, so a still or
					// unaware target, another player's copy and an NPC another game hosts got none however often they were
					// hit (11/11/2026: 12 Flames hits on a still wolf, no bar). A hit by the player itself, or on the player
					// itself, now adds the bar at once and keeps it for fInfoBarFightKeepTime (NoteActorFight), in combat
					// or not. Teammates' hits keep TrueHUD's rule, and so does everything while the keep time is 0
					const bool bFightsEnabled = Settings::fInfoBarFightKeepTime > 0.f;

					if (bCausePlayer || bCausePlayerTeammate) {
						bool bHasBossBarAlready = trueHUDMenu->HasBossInfoBar(targetActorHandle);
						if (bHasBossBarAlready) {
							return EventResult::kContinue;
						}

						if (Settings::bEnableBossBars && targetActor->IsInCombat() && CheckActorForBoss(targetActorHandle)) {
							HUDHandler::GetSingleton()->AddBossInfoBar(targetActorHandle);
						} else if (bInfoBarsEnabled) {  // Not a boss, add a normal info bar
							bool bShowsBars = false;
							if (targetActor->IsHostileToActor(playerCharacter)) {
								bShowsBars = Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kNever;
							} else if (!bTargetPlayerTeammate) {  // don't show info bars on teammates when hit by player
								bShowsBars = Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kNever;
							}

							if (bShowsBars && bCausePlayer && bFightsEnabled) {
								HUDHandler::GetSingleton()->NoteActorFight(targetActorHandle);
							} else if (bShowsBars && targetActor->IsInCombat()) {
								HUDHandler::GetSingleton()->AddActorInfoBar(targetActorHandle);
							}
						}
					} else if (bTargetPlayer || bTargetPlayerTeammate) {
						bool bHasBossBarAlready = trueHUDMenu->HasBossInfoBar(causeActorHandle);
						if (bHasBossBarAlready) {
							return EventResult::kContinue;
						}

						if (Settings::bEnableBossBars && causeActor->IsInCombat() && CheckActorForBoss(causeActorHandle)) {
							HUDHandler::GetSingleton()->AddBossInfoBar(causeActorHandle);
						} else if (bInfoBarsEnabled) {  // Not a boss, add a normal info bar
							bool bShowsBars = false;
							if (causeActor->IsHostileToActor(playerCharacter)) {
								bShowsBars = Settings::uInfoBarDisplayHostiles > InfoBarsDisplayMode::kNever;
							} else if (!bCausePlayerTeammate) {  // don't show info bars on teammates when they hit player
								bShowsBars = Settings::uInfoBarDisplayOthers > InfoBarsDisplayMode::kNever;
							}

							if (bShowsBars && bTargetPlayer && bFightsEnabled) {
								HUDHandler::GetSingleton()->NoteActorFight(causeActorHandle);
							} else if (bShowsBars && causeActor->IsInCombat()) {
								HUDHandler::GetSingleton()->AddActorInfoBar(causeActorHandle);
							}
						}
					}
				}
			}
		}
	}

	return EventResult::kContinue;
}

HUDHandler::EventResult HUDHandler::ProcessEvent(const RE::MenuOpenCloseEvent* a_event, RE::BSTEventSource<RE::MenuOpenCloseEvent>*)
{
	using ContextID = RE::UserEvents::INPUT_CONTEXT_ID;
	// On HUD menu open/close - open/close the plugin's HUD menu
	if (a_event && a_event->menuName == RE::HUDMenu::MENU_NAME) {
		if (a_event->opening) {
			HUDHandler::GetSingleton()->OpenTrueHUDMenu();
		} else {
			HUDHandler::GetSingleton()->CloseTrueHUDMenu();
		}
	}

	// Dovakarn: what was taken in a container, barter or gift menu shows once it closes
	if (a_event && !a_event->opening &&
		(a_event->menuName == RE::ContainerMenu::MENU_NAME || a_event->menuName == RE::BarterMenu::MENU_NAME ||
			a_event->menuName == RE::GiftMenu::MENU_NAME)) {
		HUDHandler::GetSingleton()->FlushHeldRecentLoot();
	}

	// Hide the widgets when a menu is open
	if (const auto controlMap = RE::ControlMap::GetSingleton()) {
		const auto& priorityStack = controlMap->GetRuntimeData().contextPriorityStack;
		if (priorityStack.empty()) {
			HUDHandler::GetSingleton()->SetMenuVisibilityMode(MenuVisibilityMode::kHidden);
		} else if (priorityStack.back() == ContextID::kGameplay ||
				   priorityStack.back() == ContextID::kFavorites ||
				   priorityStack.back() == ContextID::kConsole) {
			HUDHandler::GetSingleton()->SetMenuVisibilityMode(MenuVisibilityMode::kVisible);
		} else if ((priorityStack.back() == ContextID::kCursor ||
					   priorityStack.back() == ContextID::kItemMenu ||
					   priorityStack.back() == ContextID::kMenuMode ||
					   priorityStack.back() == ContextID::kInventory) &&
				   (RE::UI::GetSingleton()->IsMenuOpen(RE::DialogueMenu::MENU_NAME) ||
					   !Settings::bRecentLootHideInCraftingMenus && RE::UI::GetSingleton()->IsMenuOpen(RE::CraftingMenu::MENU_NAME) ||
					   !Settings::bRecentLootHideInInventoryMenus && (RE::UI::GetSingleton()->IsMenuOpen(RE::BarterMenu::MENU_NAME) ||
																		 RE::UI::GetSingleton()->IsMenuOpen(RE::ContainerMenu::MENU_NAME) ||
																		 RE::UI::GetSingleton()->IsMenuOpen(RE::GiftMenu::MENU_NAME) ||
																		 RE::UI::GetSingleton()->IsMenuOpen(RE::InventoryMenu::MENU_NAME)))) {
			HUDHandler::GetSingleton()->SetMenuVisibilityMode(MenuVisibilityMode::kPartial);
		} else {
			HUDHandler::GetSingleton()->SetMenuVisibilityMode(MenuVisibilityMode::kHidden);
		}
	}

	return EventResult::kContinue;
}

void HUDHandler::OpenTrueHUDMenu()
{
	if (!IsTrueHUDMenuOpen()) {
		auto msgQ = RE::UIMessageQueue::GetSingleton();
		if (msgQ) {
			msgQ->AddMessage(TrueHUDMenu::MenuName(), RE::UI_MESSAGE_TYPE::kShow, nullptr);
		}
	}
}

void HUDHandler::CloseTrueHUDMenu()
{
	if (IsTrueHUDMenuOpen()) {
		auto msgQ = RE::UIMessageQueue::GetSingleton();
		if (msgQ) {
			msgQ->AddMessage(TrueHUDMenu::MenuName(), RE::UI_MESSAGE_TYPE::kHide, nullptr);
		}
	}
}

bool HUDHandler::IsTrueHUDMenuOpen()
{
	auto trueHUD = GetTrueHUDMenu();
	if (trueHUD) {
		return trueHUD->IsOpen();
	}
	return false;
}

RE::GPtr<Scaleform::TrueHUDMenu> HUDHandler::GetTrueHUDMenu()
{
	auto ui = RE::UI::GetSingleton();
	return ui ? ui->GetMenu<TrueHUDMenu>(TrueHUDMenu::MenuName()) : nullptr;
}

void HUDHandler::Update()
{

}

RE::ObjectRefHandle HUDHandler::GetTarget() const
{
	return _currentTarget;
}

RE::ObjectRefHandle HUDHandler::GetSoftTarget() const
{
	return _currentSoftTarget;
}

void HUDHandler::SetTarget(RE::ObjectRefHandle a_actorHandle)
{
	if (a_actorHandle.native_handle() == 0x100000) {
		return;
	}

	AddHUDTask([a_actorHandle](TrueHUDMenu& a_menu) {
		a_menu.SetTarget(a_actorHandle);
	});

#ifdef DOVAKARN_DEV
	if (Settings::bInfoBarLog && _currentTarget != a_actorHandle) {
		logger::info("target: [{}]", Utils::Describe(a_actorHandle));
	}
#endif

	_currentTarget = a_actorHandle;
}

void HUDHandler::SetSoftTarget(RE::ObjectRefHandle a_actorHandle)
{
	if (a_actorHandle.native_handle() == 0x100000) {
		return;
	}

	AddHUDTask([a_actorHandle](TrueHUDMenu& a_menu) {
		a_menu.SetSoftTarget(a_actorHandle);
	});

#ifdef DOVAKARN_DEV
	if (Settings::bInfoBarLog && _currentSoftTarget != a_actorHandle) {
		logger::info("soft target: [{}]", Utils::Describe(a_actorHandle));
	}
#endif

	_currentSoftTarget = a_actorHandle;
}

bool HUDHandler::HasActorInfoBar(RE::ObjectRefHandle a_actorHandle)
{
	return GetTrueHUDMenu()->HasActorInfoBar(a_actorHandle);
}

void HUDHandler::AddActorInfoBar(RE::ObjectRefHandle a_actorHandle)
{
	if (!Settings::bEnableActorInfoBars) {
		return;
	}

	if (a_actorHandle.native_handle() == 0x100000) {
		return;
	}

	if (a_actorHandle) {
		AddHUDTask([a_actorHandle](TrueHUDMenu& a_menu) {
			[[maybe_unused]] const bool bAdded = a_menu.AddActorInfoBar(a_actorHandle);
			DOV_BAR_LOG("bar asked for [{}]: {}", Utils::Describe(a_actorHandle), bAdded ? "added" : "not added (it has one, or the movie gave no widget)");
		});
	}
}

// Dovakarn: the player hit this actor or was hit by it (the hit event, on whichever thread the game raises it). Only the
// handle crosses to the menu's thread, as a HUD task under _lock like every other request; the bar and its keep time are
// touched there alone (TrueHUDMenu::NoteActorFight)
void HUDHandler::NoteActorFight(RE::ObjectRefHandle a_actorHandle)
{
	if (!Settings::bEnableActorInfoBars) {
		return;
	}

	if (a_actorHandle.native_handle() == 0x100000) {
		return;
	}

	if (a_actorHandle) {
		AddHUDTask([a_actorHandle](TrueHUDMenu& a_menu) {
			[[maybe_unused]] const bool bKept = a_menu.NoteActorFight(a_actorHandle);
			DOV_BAR_LOG("fight noted [{}]: {}", Utils::Describe(a_actorHandle), bKept ? "its bar is kept" : "no bar (it has a boss bar, or the movie gave no widget)");
		});
	}
}

void HUDHandler::RemoveActorInfoBar(RE::ObjectRefHandle a_actorHandle, WidgetRemovalMode a_removalMode /*= kImmediate*/)
{
	if (a_actorHandle) {
		AddHUDTask([a_actorHandle, a_removalMode](TrueHUDMenu& a_menu) {
			[[maybe_unused]] const bool bHad = a_menu.RemoveActorInfoBar(a_actorHandle, a_removalMode);
#ifdef DOVAKARN_DEV
			if (bHad) {
				DOV_BAR_LOG("bar removal asked for [{}], mode {}", Utils::Describe(a_actorHandle), static_cast<uint32_t>(a_removalMode));
			}
#endif
		});
	}
}

// Dovakarn: the actor's combat ended (the combat event). TrueHUD's own removal, unless a fight with the player still keeps
// the bar; decided on the menu's thread, where the keep time lives
void HUDHandler::RemoveActorInfoBarOnCombatEnd(RE::ObjectRefHandle a_actorHandle)
{
	if (a_actorHandle) {
		AddHUDTask([a_actorHandle](TrueHUDMenu& a_menu) {
			[[maybe_unused]] const bool bLeaving = a_menu.RemoveActorInfoBarOnCombatEnd(a_actorHandle);
			DOV_BAR_LOG("combat over for [{}]: {}", Utils::Describe(a_actorHandle), bLeaving ? "its bar leaves" : "no bar, or a fight with the player still keeps it");
		});
	}
}

bool HUDHandler::HasBossInfoBar(RE::ObjectRefHandle a_actorHandle)
{
	return GetTrueHUDMenu()->HasBossInfoBar(a_actorHandle);
}

void HUDHandler::AddBossInfoBar(RE::ObjectRefHandle a_actorHandle)
{
	if (!Settings::bEnableBossBars) {
		return;
	}

	if (a_actorHandle.native_handle() == 0x100000) {
		return;
	}

	if (a_actorHandle) {
		AddHUDTask([a_actorHandle](TrueHUDMenu& a_menu) {
			a_menu.AddBossInfoBar(a_actorHandle);
		});
	}
}

void HUDHandler::RemoveBossInfoBar(RE::ObjectRefHandle a_actorHandle, WidgetRemovalMode a_removalMode /*= kImmediate*/)
{
	if (a_actorHandle) {
		AddHUDTask([a_actorHandle, a_removalMode](TrueHUDMenu& a_menu) {
			a_menu.RemoveBossInfoBar(a_actorHandle, a_removalMode);
		});
	}
}

void HUDHandler::AddShoutIndicator()
{
	AddHUDTask([](TrueHUDMenu& a_menu) {
		a_menu.AddShoutIndicator();
	});
}

void HUDHandler::RemoveShoutIndicator()
{
	AddHUDTask([](TrueHUDMenu& a_menu) {
		a_menu.RemoveShoutIndicator();
	});
}

void HUDHandler::AddPlayerWidget()
{
	if (!Settings::bEnablePlayerWidget) {
		return;
	}

	AddHUDTask([](TrueHUDMenu& a_menu) {
		a_menu.AddPlayerWidget();
	});
}

void HUDHandler::RemovePlayerWidget()
{
	AddHUDTask([](TrueHUDMenu& a_menu) {
		a_menu.RemovePlayerWidget();
	});
}

void HUDHandler::UpdatePlayerWidgetChargeMeters(float a_percent, bool a_bForce, bool a_bLeftHand, bool a_bShow)
{
	if (!Settings::bEnablePlayerWidget || !Settings::bPlayerWidgetDisplayEnchantmentChargeMeter) {
		return;
	}

	AddHUDTask([a_percent, a_bForce, a_bLeftHand, a_bShow](TrueHUDMenu& a_menu) {
		a_menu.UpdatePlayerWidgetChargeMeters(a_percent, a_bForce, a_bLeftHand, a_bShow);
	});
}

void HUDHandler::AddRecentLootWidget()
{
	if (!Settings::bEnableRecentLoot) {
		return;
	}

	AddHUDTask([](TrueHUDMenu& a_menu) {
		a_menu.AddRecentLootWidget();
	});
}

void HUDHandler::RemoveRecentLootWidget()
{
	AddHUDTask([](TrueHUDMenu& a_menu) {
		a_menu.RemoveRecentLootWidget();
	});
}

void HUDHandler::AddRecentLootMessage(RE::TESBoundObject* a_object, std::string_view a_name, uint32_t a_count)
{
	if (!Settings::bEnableRecentLoot) {
		return;
	}

	if (a_name.length() == 0 || a_name == ""sv || a_name == " "sv) {
		return;
	}

	// Dovakarn: the server's own pack being put back is not an arrival
	if (IsRecentLootQuiet()) {
		return;
	}

	// Don't show message when those menus are open. Dovakarn: hold it and show it once the menu closes, as what was taken
	// there did arrive (FlushHeldRecentLoot, from the menu's close event); the same item taken twice is one line
	if (Settings::bRecentLootHideInInventoryMenus &&
		(RE::UI::GetSingleton()->IsMenuOpen(RE::BarterMenu::MENU_NAME) ||
			RE::UI::GetSingleton()->IsMenuOpen(RE::ContainerMenu::MENU_NAME) ||
			RE::UI::GetSingleton()->IsMenuOpen(RE::GiftMenu::MENU_NAME))) {
		Locker locker(_lock);
		for (auto& held : _heldLoot) {
			if (held.object == a_object && held.name == a_name) {
				held.count += a_count;
				return;
			}
		}
		if (_heldLoot.size() < 64) {
			_heldLoot.push_back({ a_object, std::string(a_name), a_count });
		}
		return;
	}

	if (Settings::bRecentLootHideInCraftingMenus &&
		RE::UI::GetSingleton()->IsMenuOpen(RE::CraftingMenu::MENU_NAME)) {
		return;
	}

	// Dovakarn: the name is copied, as the task runs later and a reference's display name can be gone by then
	AddHUDTask([a_object, name = std::string(a_name), a_count](TrueHUDMenu& a_menu) {
		a_menu.AddRecentLootMessage(a_object, name, a_count);
	});
}

void HUDHandler::QuietRecentLoot(float a_seconds)
{
	const auto now = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
	const float seconds = std::clamp(a_seconds, 0.f, 60.f);
	_quietUntilMs = seconds > 0.f ? now + static_cast<int64_t>(seconds * 1000.f) : 0;
}

bool HUDHandler::IsRecentLootQuiet() const
{
	const auto until = _quietUntilMs.load();
	if (until == 0) {
		return false;
	}
	const auto now = std::chrono::duration_cast<std::chrono::milliseconds>(std::chrono::steady_clock::now().time_since_epoch()).count();
	return now < until;
}

void HUDHandler::FlushHeldRecentLoot()
{
	std::vector<HeldLoot> held;
	{
		Locker locker(_lock);
		held.swap(_heldLoot);
	}
	if (!Settings::bEnableRecentLoot) {
		return;
	}
	for (auto& item : held) {
		AddHUDTask([object = item.object, name = std::move(item.name), count = item.count](TrueHUDMenu& a_menu) {
			a_menu.AddRecentLootMessage(object, name, count);
		});
	}
}

void HUDHandler::AddFloatingWorldTextWidget(std::string a_text, uint32_t a_color, float a_duration, bool a_bSpecial, RE::NiPoint3 a_worldPosition)
{
	if (!Settings::bEnableFloatingText) {
		return;
	}

	AddHUDTask([a_text, a_color, a_duration, a_bSpecial, a_worldPosition](TrueHUDMenu& a_menu) {
		a_menu.AddFloatingWorldTextWidget(a_text, a_color, a_duration, a_bSpecial, a_worldPosition);
	});
}

void HUDHandler::AddFloatingScreenTextWidget(std::string a_text, uint32_t a_color, float a_duration, bool a_bSpecial, RE::NiPoint2 a_screenPosition)
{
	if (!Settings::bEnableFloatingText) {
		return;
	}

	AddHUDTask([a_text, a_color, a_duration, a_bSpecial, a_screenPosition](TrueHUDMenu& a_menu) {
		a_menu.AddFloatingScreenTextWidget(a_text, a_color, a_duration, a_bSpecial, a_screenPosition);
	});
}

void HUDHandler::AddStackingDamageWorldTextWidget(RE::ObjectRefHandle a_refHandle, float a_damage)
{
	if (!Settings::bEnableFloatingText) {
		return;
	}

	auto it = _stackingDamage.find(a_refHandle);
	if (it != _stackingDamage.end()) {
		it->second.damage += a_damage;
	} else {
		_stackingDamage.emplace(a_refHandle, a_damage);
	}
}

void HUDHandler::OverrideBarColor(RE::ActorHandle a_actorHandle, RE::ActorValue a_actorValue, BarColorType a_colorType, uint32_t a_color)
{
	AddHUDTask([a_actorHandle, a_actorValue, a_colorType, a_color](TrueHUDMenu& a_menu) {
		a_menu.OverrideBarColor(a_actorHandle, a_actorValue, a_colorType, a_color);
	});
}

void HUDHandler::OverrideSpecialBarColor(RE::ActorHandle a_actorHandle, BarColorType a_colorType, uint32_t a_color)
{
	AddHUDTask([a_actorHandle, a_colorType, a_color](TrueHUDMenu& a_menu) {
		a_menu.OverrideSpecialBarColor(a_actorHandle, a_colorType, a_color);
	});
}

void HUDHandler::RevertBarColor(RE::ActorHandle a_actorHandle, RE::ActorValue a_actorValue, BarColorType a_colorType)
{
	AddHUDTask([a_actorHandle, a_actorValue, a_colorType](TrueHUDMenu& a_menu) {
		a_menu.RevertBarColor(a_actorHandle, a_actorValue, a_colorType);
	});
}

void HUDHandler::RevertSpecialBarColor(RE::ActorHandle a_actorHandle, BarColorType a_colorType)
{
	AddHUDTask([a_actorHandle, a_colorType](TrueHUDMenu& a_menu) {
		a_menu.RevertSpecialBarColor(a_actorHandle, a_colorType);
	});
}

void HUDHandler::LoadCustomWidgets(SKSE::PluginHandle a_pluginHandle, std::string_view a_filePath, APIResultCallback&& a_successCallback)
{
	AddHUDTask([a_pluginHandle, a_filePath, a_successCallback = std::forward<APIResultCallback>(a_successCallback)](TrueHUDMenu& a_menu) mutable {
		a_menu.LoadCustomWidgets(a_pluginHandle, a_filePath, std::move(a_successCallback));
	});
}

void HUDHandler::RegisterNewWidgetType(SKSE::PluginHandle a_pluginHandle, uint32_t a_widgetType)
{
	AddHUDTask([a_pluginHandle, a_widgetType](TrueHUDMenu& a_menu) {
		a_menu.RegisterNewWidgetType(a_pluginHandle, a_widgetType);
	});
}

void HUDHandler::AddWidget(SKSE::PluginHandle a_pluginHandle, uint32_t a_widgetType, uint32_t a_widgetID, std::string_view a_symbolIdentifier, std::shared_ptr<WidgetBase> a_widget)
{
	AddHUDTask([a_pluginHandle, a_widgetType, a_widgetID, a_symbolIdentifier, a_widget](TrueHUDMenu& a_menu) {
		a_menu.AddWidget(a_pluginHandle, a_widgetType, a_widgetID, a_symbolIdentifier, a_widget);
	});
}

void HUDHandler::RemoveWidget(SKSE::PluginHandle a_pluginHandle, uint32_t a_widgetType, uint32_t a_widgetID, WidgetRemovalMode a_removalMode)
{
	AddHUDTask([a_pluginHandle, a_widgetType, a_widgetID, a_removalMode](TrueHUDMenu& a_menu) mutable {
		a_menu.RemoveWidget(a_pluginHandle, a_widgetType, a_widgetID, a_removalMode);
	});
}

void HUDHandler::FlashActorValue(RE::ObjectRefHandle a_actorHandle, RE::ActorValue a_actorValue, bool a_bLong)
{
	AddHUDTask([a_actorHandle, a_actorValue, a_bLong](TrueHUDMenu& a_menu) {
		a_menu.FlashActorValue(a_actorHandle, a_actorValue, a_bLong);
	});
}

void HUDHandler::FlashActorSpecialBar(RE::ObjectRefHandle a_actorHandle, bool a_bLong)
{
	AddHUDTask([a_actorHandle, a_bLong](TrueHUDMenu& a_menu) {
		a_menu.FlashActorSpecialBar(a_actorHandle, a_bLong);
	});
}

void HUDHandler::DrawLine(const RE::NiPoint3& a_start, const RE::NiPoint3& a_end, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_start, a_end, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawLine(a_start, a_end, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawPoint(const RE::NiPoint3& a_position, float a_size, float a_duration, uint32_t a_color)
{
	AddHUDTask([a_position, a_size, a_duration, a_color](TrueHUDMenu& a_menu) {
		a_menu.DrawPoint(a_position, a_size, a_duration, a_color);
	});
}

void HUDHandler::DrawArrow(const RE::NiPoint3& a_start, const RE::NiPoint3& a_end, float a_size, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_start, a_end, a_size, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawArrow(a_start, a_end, a_size, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawBox(const RE::NiPoint3& a_center, const RE::NiPoint3& a_extent, const RE::NiQuaternion& a_rotation, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_center, a_extent, a_rotation, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawBox(a_center, a_extent, a_rotation, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawCircle(const RE::NiPoint3& a_center, const RE::NiPoint3& a_x, const RE::NiPoint3& a_y, float a_radius, uint32_t a_segments, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_center, a_x, a_y, a_radius, a_segments, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawCircle(a_center, a_x, a_y, a_radius, a_segments, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawHalfCircle(const RE::NiPoint3& a_center, const RE::NiPoint3& a_x, const RE::NiPoint3& a_y, float a_radius, uint32_t a_segments, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_center, a_x, a_y, a_radius, a_segments, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawHalfCircle(a_center, a_x, a_y, a_radius, a_segments, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawSphere(const RE::NiPoint3& a_origin, float a_radius, uint32_t a_segments, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_origin, a_radius, a_segments, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawSphere(a_origin, a_radius, a_segments, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawCylinder(const RE::NiPoint3& a_start, const RE::NiPoint3& a_end, float a_radius, uint32_t a_segments, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_start, a_end, a_radius, a_segments, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawCylinder(a_start, a_end, a_radius, a_segments, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawCone(const RE::NiPoint3& a_origin, const RE::NiPoint3& a_direction, float a_length, float a_angleWidth, float a_angleHeight, uint32_t a_segments, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_origin, a_direction, a_length, a_angleWidth, a_angleHeight, a_segments, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawCone(a_origin, a_direction, a_length, a_angleWidth, a_angleHeight, a_segments, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawCapsule(const RE::NiPoint3& a_origin, float a_halfHeight, float a_radius, const RE::NiQuaternion& a_rotation, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_origin, a_halfHeight, a_radius, a_rotation, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawCapsule(a_origin, a_halfHeight, a_radius, a_rotation, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::DrawCapsule(const RE::NiPoint3& a_vertexA, const RE::NiPoint3& a_vertexB, float a_radius, float a_duration, uint32_t a_color, float a_thickness)
{
	AddHUDTask([a_vertexA, a_vertexB, a_radius, a_duration, a_color, a_thickness](TrueHUDMenu& a_menu) {
		a_menu.DrawCapsule(a_vertexA, a_vertexB, a_radius, a_duration, a_color, a_thickness);
	});
}

void HUDHandler::SetMenuVisibilityMode(MenuVisibilityMode a_mode)
{
	AddHUDTask([a_mode](TrueHUDMenu& a_menu) {
		a_menu.SetMenuVisibilityMode(a_mode);
	});
}

void HUDHandler::SetCartMode(bool a_enable)
{
	AddHUDTask([a_enable](TrueHUDMenu& a_menu) {
		a_menu.SetCartMode(a_enable);
	});
}

void HUDHandler::RemoveAllWidgets()
{
	AddHUDTask([](TrueHUDMenu& a_menu) {
		a_menu.RemoveAllWidgets();
	});
}

bool HUDHandler::CheckActorForBoss(RE::ObjectRefHandle a_refHandle)
{
	if (!a_refHandle) {
		return false;
	}

	auto playerCharacter = RE::PlayerCharacter::GetSingleton();
	auto actor = a_refHandle.get()->As<RE::Actor>();
	if (actor && playerCharacter && (actor != playerCharacter)) {
		// Check whether the target is even alive or hostile first
		if (actor->IsDead() || (actor->AsActorState()->IsBleedingOut() && actor->IsEssential()) || !actor->IsHostileToActor(playerCharacter)) {
			return false;
		}

		auto actorBase = actor->GetActorBase();
		RE::TESActorBase* originalBase = nullptr;

		auto extraLeveledCreature = static_cast<RE::ExtraLeveledCreature*>(actor->extraList.GetByType(RE::ExtraDataType::kLeveledCreature));
		if (extraLeveledCreature) {
			originalBase = extraLeveledCreature->originalBase;
		}

		// Check blacklist
		if (Settings::bossNPCBlacklist.contains(actorBase) || (originalBase && Settings::bossNPCBlacklist.contains(originalBase))) {
			return false;
		}

		// Check race
		if (Settings::bossRaces.contains(actor->GetRace())) {
			return true;
		}

		// Check NPC
		if (Settings::bossNPCs.contains(actorBase) || (originalBase && Settings::bossNPCs.contains(originalBase))) {
			return true;
		}

		// Check current loc refs
		if (auto currentLocation = playerCharacter->GetPlayerRuntimeData().currentLocation) {
			for (auto& ref : currentLocation->specialRefs) {
				if (ref.type && Settings::bossLocRefTypes.contains(ref.type) && ref.refData.refID == actor->formID) {
					return true;
				}
			}
		}
	}

	return false;
}

void HUDHandler::OnPreLoadGame()
{
	//RemoveAllWidgets();
	//_bossTargets.clear();
}

void HUDHandler::OnSettingsUpdated()
{
	if (IsTrueHUDMenuOpen()) {
		AddHUDTask([](TrueHUDMenu& a_menu) {
			logger::info("Updating settings...");
			a_menu.UpdateSettings();
			logger::info("...success");
		});
	}
}

void HUDHandler::Initialize()
{
	
}

void HUDHandler::Process(TrueHUDMenu& a_menu, float a_deltaTime)
{
	// Dovakarn: the waiting tasks are taken out under the lock AddHUDTask puts them in under, then run outside it, in order.
	// TrueHUD read and popped the queue here with no lock, while a game event on another thread could be pushing to it.
	// A task that asks for another one is still served in this same pass, as before
	for (;;) {
		std::queue<HUDTask> tasks;
		{
			Locker locker(_lock);
			tasks.swap(_taskQueue);
		}
		if (tasks.empty()) {
			break;
		}
		while (!tasks.empty()) {
			auto& task = tasks.front();
			task(a_menu);
			tasks.pop();
		}
	}

	for (auto it = _stackingDamage.begin(), next_it = it; it != _stackingDamage.end(); it = next_it) {
		++next_it;
		DamageStack& damageStack = it->second;
		damageStack.timeElapsed += a_deltaTime;
		if (damageStack.timeElapsed > _stackingPeriodDuration) {
			if (auto actor = it->first.get().get()) {
				HUDHandler::GetSingleton()->AddFloatingWorldTextWidget(std::to_string(static_cast<int32_t>(ceil(damageStack.damage))), 0xFFFFFF, 2.f, false, actor->GetLookingAtLocation());
			}
			_stackingDamage.erase(it);
		}
	}
}

HUDHandler::HUDHandler() :
	_lock()
{}

void HUDHandler::AddHUDTask(HUDTask a_task)
{
	OpenTrueHUDMenu();
	Locker locker(_lock);
	_taskQueue.push(std::move(a_task));
}
