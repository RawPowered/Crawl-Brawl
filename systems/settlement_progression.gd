class_name SettlementProgression
extends RefCounted

## Early underground-settlement campaign gate. This deliberately stops before
## the Final Five / surface transition; those remain later campaign progression.

const MERCHANT_STORE_STOCK_ID := "merchant_store"
const REQUIRED_FIELD_LANTERNS := 2
const MERCHANT_STORE_SAFE_RADIUS_CELLS := 8.0
const MERCHANT_STORE_FOOTPRINT := Vector2i(4, 3)
const MERCHANT_STORE_MAX_HEALTH := 520.0


static func merchant_invite_gate(breached: bool, opening_contact_complete: bool, field_lanterns: int) -> String:
	if not breached:
		return "BREACH THE LANDING SEAL"
	if not opening_contact_complete:
		return "SURVIVE INITIAL TUNNEL CONTACT"
	if field_lanterns < REQUIRED_FIELD_LANTERNS:
		return "PLACE %d FIELD LANTERNS (%d/%d)" % [REQUIRED_FIELD_LANTERNS, field_lanterns, REQUIRED_FIELD_LANTERNS]
	return "READY"


static func merchant_invite_ready(breached: bool, opening_contact_complete: bool, field_lanterns: int) -> bool:
	return merchant_invite_gate(breached, opening_contact_complete, field_lanterns) == "READY"


static func merchant_store_detail() -> String:
	return "The first volunteer merchant will descend only after the landing pocket proves survivable. Establish the store to create the first civilian foothold underground."
