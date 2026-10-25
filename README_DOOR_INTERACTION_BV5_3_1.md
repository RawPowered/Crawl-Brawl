# Crawl Brawl BV5.3.1 - Clickable Heavy Doorway

Baseline: `BV5-DEV005` (`90e4e5c219b8c41c1b214a731deba26610b97812fdff7476b2a18fbb0885f769`).

## Fix

Heavy Doorways are now first-class world-click targets. While the operator is within doorway interaction range, the mouse cursor remains available and clicking anywhere on the full multi-cell doorway footprint toggles it immediately between OPEN and CLOSED. The existing F-hold interaction remains available.

Both inputs use `_toggle_doorway()`, which synchronizes:

- `Structure.is_open`
- enemy blocker cache
- affected flow regions
- actor/effects redraw
- player feedback
- realm save

An out-of-range click on a visible doorway is consumed and reports `MOVE CLOSER TO OPERATE DOORWAY`, so clicking the door does not accidentally fire the equipped weapon.

The HUD proximity prompt now reports `CLICK/F DOOR // OPEN|CLOSED`.

## Validation

`door_click_interaction_bv531_test.gd` covers click target resolution, cursor eligibility, HUD prompt, open/close toggling, primary-fire suppression, immediate blocker refresh, and out-of-range behavior. It is registered in `run_regression_batch.gd`.

Godot 4.7.1 runtime validation remains the local launcher gate.
