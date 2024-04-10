/datum/keybinding/client
	category = KEYBIND_CATEGORY_CLIENT

/datum/keybinding/client/admin_help
	name = "admin_help"
	full_name = "Admin Help"
	description = "Ask an admin for help"
	hotkey_keys = list("F1")

/datum/keybinding/client/admin_help/down(client/user)
	user.adminhelp()
	return TRUE

/datum/keybinding/client/screenshot
	name = "screenshot"
	full_name = "Screenshot"
	description = "Take a screenshot"
	hotkey_keys = list()

/datum/keybinding/client/screenshot/down(client/user)
	winset(user, null, "command=.screenshot [!user.keys_held[SHIFT_CLICK] ? "auto" : ""]")
	return TRUE

/datum/keybinding/client/fit_viewport
	name = "fit_viewport"
	full_name = "Fit Viewport"
	description = "Fits your viewport"
	hotkey_keys = list("F11")

/datum/keybinding/client/fit_viewport/down(client/user)
	user.fit_viewport()
	return TRUE

/datum/keybinding/client/toggle_fullscreen
	name = "toggle_fullscreen"
	full_name = "Toggle Fullscreen"
	description = "Opens game in fullscreen / Collapses to window"
	hotkey_keys = list("F12")

/datum/keybinding/client/toggle_fullscreen/down(client/user)
	user.toggle_fullscreen()
	return TRUE

/datum/keybinding/client/minimal_hud
	name = "minimal_hud"
	full_name = "Minimal HUD"
	description = "Hide most HUD features"
	hotkey_keys = list("CtrlF12")

/datum/keybinding/client/minimal_hud/down(client/user)
	user.mob.button_pressed_F12()
	return TRUE
