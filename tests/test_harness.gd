class_name TestHarness
extends RefCounted

static var failed := false


static func reset() -> void:
	failed = false


static func require(condition: bool, message: String) -> void:
	if condition:
		return
	failed = true
	push_error(message)


static func fail(message: String) -> void:
	failed = true
	push_error(message)


static func finish(tree: SceneTree, success_token: String) -> void:
	if failed:
		tree.quit(1)
		return
	print(success_token)
	tree.quit(0)


static func project_root() -> String:
	return ProjectSettings.globalize_path("res://")


static func godot_executable() -> String:
	return OS.get_executable_path()


static func run_script(script_path: String, timeout_sec: int = 120) -> Dictionary:
	var output: Array[String] = []
	var args: PackedStringArray = [
		"--headless",
		"--path",
		project_root(),
		"--script",
		script_path,
	]
	var exit_code := OS.execute(godot_executable(), args, output, true, false)
	var joined := "\n".join(output)
	return {
		"exit_code": exit_code,
		"output": joined,
		"ok": exit_code == 0 and success_token_present(joined) and not error_present(joined),
	}


static func success_token_present(output: String) -> bool:
	return "_TEST_OK" in output


static func error_present(output: String) -> bool:
	return (
		"SCRIPT ERROR:" in output
		or "Parse Error:" in output
		or "Assertion failed:" in output
		or "Invalid access" in output
		or "Compile Error:" in output
	)
