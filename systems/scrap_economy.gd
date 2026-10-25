class_name ScrapEconomy
extends RefCounted

# One contract for every scrap credit source. Shop prices stay authored in phase0_run.
const START := 120
const KILL_SMALL := 6
const KILL_BIG := 24
const KILL_SENTRY_RATIO := 0.75
const BROODLING := 2
const GUARDIAN := 100
const NEST := 60
const MINE_CELL := 2
const SECTOR := 8
const EXPLORER_STREAK := 30
const SUPPLY_CACHE := 35
const WAVE_BASE := 30
const WAVE_PER := 3


static func kill_reward(big: bool, sentry_kill: bool) -> int:
	var base := KILL_BIG if big else KILL_SMALL
	if sentry_kill:
		return ceili(float(base) * KILL_SENTRY_RATIO)
	return base


static func wave_reward(wave: int, reward_multiplier: float) -> int:
	return roundi(float(WAVE_BASE + wave * WAVE_PER) * reward_multiplier)
