/datum/keybinding/client/communication
	category = KEYBIND_CATEGORY_COMMUNICATION

/datum/keybinding/client/communication/say
	name = "IC Say"
	full_name = "IC Say"
	hotkey_keys = list("F3", "T")

/datum/keybinding/client/communication/say/down(client/user)
	user.mob.say_wrapper()
	return TRUE

/datum/keybinding/client/communication/whisper
	name = "Whisper"
	full_name = "Whisper"
	hotkey_keys = list("ShiftT")

/datum/keybinding/client/communication/whisper/down(client/user)
	user.mob.whisper_wrapper()
	return TRUE

/datum/keybinding/client/communication/ooc
	name = "OOC"
	full_name = "Out Of Character Say (OOC)"
	hotkey_keys = list("F2")

/datum/keybinding/client/communication/looc
	name = "LOOC"
	full_name = "Local Out Of Character Say (LOOC)"
	hotkey_keys = list("L")

/datum/keybinding/client/communication/looc/down(client/user)
	user.looc()
	return TRUE

/datum/keybinding/client/communication/me
	name = "IC Me"
	full_name = "Custom Emote (/Me)"
	hotkey_keys = list("F4", "M")

/datum/keybinding/client/communication/me/down(client/user)
	user.mob.me_wrapper()
	return TRUE
