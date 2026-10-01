extends SceneTree

const CJK_FONT: Font = preload("res://assets/ui/NotoSansSC-Regular.ttf")
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var main: Node2D = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	for label_path in ["Playfield/ObjectiveLabel", "LevelTwo/ObjectiveLabel", "LevelThree/ObjectiveLabel", "LevelFour/ObjectiveLabel", "LevelFive/ObjectiveLabel"]:
		var label: Label = main.get_node(label_path) as Label
		var font := label.get_theme_font("font")
		_check(font != null and font.fallbacks.has(CJK_FONT), "%s has CJK fallback" % label_path)
	main.queue_free()
	await process_frame
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
