/datum/keybinding
	var/name
	var/full_name
	var/description = ""
	var/category = KEYBIND_CATEGORY_MISC
	var/list/hotkey_keys
	var/list/classic_keys

/datum/keybinding/New()
	// Default keys to the master "hotkey_keys"
	if(LAZYLEN(hotkey_keys) && !LAZYLEN(classic_keys))
		classic_keys = hotkey_keys.Copy()

/datum/keybinding/proc/down(client/user)
	return FALSE

/datum/keybinding/proc/up(client/user)
	return FALSE

/datum/keybinding/proc/can_use(client/user)
	return TRUE
