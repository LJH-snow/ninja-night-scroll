extends SceneTree

var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	_check(LocalePreferences.next_locale("zh") == "en" and LocalePreferences.next_locale("en") == "zh",
			"locale cycling alternates between zh and en")
	_check(LocalePreferences.toggle_label("zh") == "English" and LocalePreferences.toggle_label("en") == "中文",
			"toggle button offers the other language in its own script")

	LocalePreferences.ensure_translation_registered()
	var saved_locale_before := LocalePreferences.saved_locale()
	LocalePreferences.save_locale("en")
	TranslationServer.set_locale("en")
	_check(TranslationServer.translate("任务完成") == "Mission complete", "victory message translates to English")
	_check(TranslationServer.translate("还需收集 %d 个卷轴") % 2 == "Collect 2 more scrolls",
			"format strings translate with placeholders intact")
	TranslationServer.set_locale("zh")
	_check(TranslationServer.translate("任务完成") == "任务完成", "zh locale keeps the Chinese source text")
	_check(TranslationServer.translate("生命 %d / %d") % [3, 3] == "生命 3 / 3", "zh format strings stay intact")

	TranslationServer.set_locale("en")
	var main: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(main)
	await process_frame
	await process_frame
	_check(String(main.get_node("Title").text) == "Ninja Night Scroll: Three-Minute Escape",
			"main scene title auto-translates to English")
	_check(String(main.get("scroll_label").text) == "Scrolls 0 / 3", "script HUD labels translate to English")
	_check(main.has_node("HUD/PauseOverlay/PausePanel/LanguageButton"), "pause menu has a language toggle")
	main.call("_on_language_toggle_pressed")
	_check(TranslationServer.get_locale() == "zh", "pause toggle switches back to Chinese")
	_check(String(main.get("scroll_label").text) == "卷轴 0 / 3", "HUD labels refresh after the toggle")
	main.call("_on_language_toggle_pressed")
	_check(TranslationServer.get_locale() == "en", "pause toggle switches to English again")
	_check(String(main.get("subtitle_label").text) == "Level 1 · Old Village Path", "level subtitle translates")
	main.free()
	await process_frame

	var title: Node = load("res://scenes/title_screen.tscn").instantiate()
	root.add_child(title)
	await process_frame
	_check(String(title.get_node("TitleCard/StartButton").text) == "Start Game", "title start button auto-translates")
	_check(String(title.get_node("TitleCard/MoveLabel").text) == "WASD / Arrows\nMove", "multiline control labels translate")
	title.call("_on_language_toggle_pressed")
	_check(String(title.get_node("TitleCard/MoveLabel").text).contains("移动"), "title toggle restores Chinese labels")
	title.free()
	await process_frame

	LocalePreferences.save_locale(saved_locale_before)
	TranslationServer.set_locale(LocalePreferences.effective_locale())
	quit(1 if failures > 0 else 0)

func _check(condition: bool, label: String) -> void:
	if condition:
		print("PASS: %s" % label)
	else:
		push_error("FAIL: %s" % label)
		failures += 1
