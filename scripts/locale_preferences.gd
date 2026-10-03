class_name LocalePreferences
extends RefCounted

const SETTINGS_PATH := "user://settings.cfg"
const SUPPORTED_LOCALES: Array = ["zh", "en"]
const EN_TRANSLATION: Translation = preload("res://assets/ui/translations.en.translation")
const ZH_TRANSLATION: Translation = preload("res://assets/ui/translations.zh.translation")

static var _translation_registered := false

static func ensure_translation_registered() -> void:
	if _translation_registered:
		return
	TranslationServer.add_translation(EN_TRANSLATION)
	TranslationServer.add_translation(ZH_TRANSLATION)
	_translation_registered = true

static func saved_locale() -> String:
	var settings := ConfigFile.new()
	if settings.load(SETTINGS_PATH) != OK:
		return "auto"
	return String(settings.get_value("general", "locale", "auto"))

static func detect_locale() -> String:
	if OS.get_locale_language().begins_with("zh"):
		return "zh"
	return "en"

static func effective_locale() -> String:
	var saved := saved_locale()
	if saved in SUPPORTED_LOCALES:
		return saved
	return detect_locale()

static func apply_saved_locale() -> String:
	ensure_translation_registered()
	var locale := effective_locale()
	TranslationServer.set_locale(locale)
	return locale

static func next_locale(locale: String) -> String:
	return "en" if locale == "zh" else "zh"

static func save_locale(locale: String) -> void:
	var settings := ConfigFile.new()
	settings.load(SETTINGS_PATH)
	settings.set_value("general", "locale", locale)
	settings.save(SETTINGS_PATH)

static func toggle_label(locale: String) -> String:
	return "English" if locale == "zh" else "中文"
