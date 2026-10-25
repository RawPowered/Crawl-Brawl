extends SceneTree

const WORLD_GRID := preload("res://systems/world_grid.gd")
const WORLD_LOAD := preload("res://systems/world_load.gd")
const TEST_HARNESS := preload("res://tests/test_harness.gd")


func _initialize() -> void:
	call_deferred("_run_generator_version_gate_test")


func _run_generator_version_gate_test() -> void:
	TEST_HARNESS.reset()
	var save_data := {
		"generator_version": WORLD_GRID.GENERATOR_VERSION - 1,
		"run_seed": 12345,
		"realm_id": "realm_00003039",
		"checkpoint_exists": true,
		"difficulty_id": "bastion",
	}
	var loader = WORLD_LOAD.new()
	loader.begin("resume", 12345, "bastion", save_data)
	TEST_HARNESS.require(not loader.save_valid, "Outdated generator saves must be rejected")
	TEST_HARNESS.require(str(loader.save_error).find("OUTDATED") >= 0, "Reject message should mention outdated generator")
	TEST_HARNESS.finish(self, "GENERATOR_VERSION_GATE_TEST_OK")
