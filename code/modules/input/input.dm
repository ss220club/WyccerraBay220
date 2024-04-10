/// Set a client's focus to an object and override these procs on that object to let it handle keypresses
/// Called when a key is pressed down initially
/datum/proc/key_down(key, client/user)
	return

/// Called when a key is released
/datum/proc/key_up(key, client/user)
	return

/// Called once every frame
/datum/proc/keyLoop(client/user)
	return

/// Called every game tick
/client/keyLoop()
	holder?.keyLoop(src)
	mob.keyLoop(src)

/// Clients aren't datums so we have to define these procs indpendently.
/// These verbs are called for all key press and release events
/client/verb/keyDown(_key as text)
	set hidden = TRUE

	// So here's some eplaination why we use `instant`.
	// Due of verbs nature, you can use the same verb limited time per tick.
	// This means, you unable to perform combinated keypresses at the same time.
	// (i.e multiple movement key press for diagonal direction move)
	// (or ShiftF5 where we press two different keys at the same time)
	// In current case, we should make this verb instant.
	set instant = TRUE

	if(!user_acted(src, "was just autokicked for flooding keysends; likely abuse but potentially lagspike."))
		return

	///Check if the key is short enough to even be a real key
	if(LAZYLEN(_key) > MAX_KEYPRESS_COMMANDLENGTH)
		to_chat(src, SPAN_DANGER("Invalid KeyDown detected! You have been disconnected from the server automatically."))
		log_admin("Client [ckey] just attempted to send an invalid keypress. Keymessage was over [MAX_KEYPRESS_COMMANDLENGTH] characters, autokicking due to likely abuse.")
		message_admins("Client [ckey] just attempted to send an invalid keypress. Keymessage was over [MAX_KEYPRESS_COMMANDLENGTH] characters, autokicking due to likely abuse.")
		qdel(src)
		return

	//Focus Chat failsafe. Overrides movement checks to prevent WASD.
	if(!prefs.hotkeys && length(_key) == 1 && _key != "Alt" && _key != "Ctrl" && _key != "Shift")
		var/current_text = winget(src, "input", "text")
		winset(src, "outputwindow.input", "focus=true;text=[current_text + url_encode(_key)]")
		return

	if(length(keys_held) >= HELD_KEY_BUFFER_LENGTH && !keys_held[_key])
		keyUp(keys_held[1]) //We are going over the number of possible held keys, so let's remove the first one.

	//the time a key was pressed isn't actually used anywhere (as of 2019-9-10) but this allows easier access usage/checking
	keys_held[_key] = world.time
	if(!movement_locked)
		var/movement = movement_keys[_key]
		if(!(next_move_dir_sub & movement))
			next_move_dir_add |= movement

		if(movement)
			last_move_dir_pressed = movement

	// Client-level keybindings are ones anyone should be able to do at any time
	// Things like taking screenshots, hitting tab, and adminhelps.
	var/AltMod = keys_held["Alt"] ? "Alt" : ""
	var/CtrlMod = keys_held["Ctrl"] ? "Ctrl" : ""
	var/ShiftMod = keys_held["Shift"] ? "Shift" : ""
	var/full_key
	switch(_key)
		if("Alt", "Ctrl", "Shift")
			full_key = "[AltMod][CtrlMod][ShiftMod]"
		else
			if(AltMod || CtrlMod || ShiftMod)
				full_key = "[AltMod][CtrlMod][ShiftMod][_key]"
				key_combos_held[_key] = full_key
			else
				_key = capitalize(_key)
				full_key = _key
	var/keycount = 0
	for(var/kb_name in prefs.key_bindings[full_key])
		keycount++
		var/datum/keybinding/kb = global.keybindings_by_name[kb_name]
		if(kb.can_use(src) && kb.down(src) && keycount >= MAX_COMMANDS_PER_KEY)
			break

	holder?.key_down(full_key, src)
	mob.key_down(full_key, src)

/client/verb/keyUp(_key as text)
	set instant = TRUE
	set hidden = TRUE

	var/key_combo = key_combos_held[_key]
	if(key_combo)
		key_combos_held -= _key
		keyUp(key_combo)

	if(!keys_held[_key])
		return

	keys_held -= _key

	if(!movement_locked)
		var/movement = movement_keys[_key]
		if(!(next_move_dir_add & movement))
			next_move_dir_sub |= movement

	// We don't do full key for release, because for mod keys you
	// can hold different keys and releasing any should be handled by the key binding specifically
	for (var/kb_name in prefs.key_bindings[_key])
		var/datum/keybinding/kb = global.keybindings_by_name[kb_name]
		if(kb.can_use(src) && kb.up(src))
			break
	holder?.key_up(_key, src)
	mob.key_up(_key, src)

// removes all the existing macros
/client/proc/erase_all_macros()
	var/erase_output = ""
	var/list/macro_set = params2list(winget(src, "default.*", "command")) // The third arg doesnt matter here as we're just removing them all
	for(var/k in 1 to length(macro_set))
		var/list/split_name = splittext(macro_set[k], ".")
		var/macro_name = "[split_name[1]].[split_name[2]]" // [3] is "command"
		erase_output = "[erase_output];[macro_name].parent=null"
	winset(src, null, erase_output)


/client/proc/set_macros()
	set waitfor = FALSE

	//Reset the buffer
	reset_held_keys()
	erase_all_macros()

	var/list/macro_set = SSinput.macro_set
	for(var/k in 1 to length(macro_set))
		var/key = macro_set[k]
		var/command = macro_set[key]
		winset(src, "default-\ref[key]", "parent=default;name=[key];command=[command]")

	update_special_keybinds()

/client/proc/reset_macros(skip_alert = FALSE)
	var/ans
	if(!skip_alert)
		ans = alert(src, "Change your keyboard language to ENG", "Reset macros")

	if(skip_alert || ans)
		set_macros()
		to_chat(src, SPAN_NOTICE("Keybindings were fixed.")) // not yet but set_macros works fast enough

/**
 * Manually clears any held keys, in case due to lag or other undefined behavior a key gets stuck.
 *
 * Hardcoded to the ESC key.
 */
/client/verb/reset_held_keys()
	set name = "Reset Held Keys"
	set hidden = TRUE

	for(var/key in keys_held)
		keyUp(key)

	//In case one got stuck and the previous loop didn't clean it, somehow.
	for(var/key in key_combos_held)
		keyUp(key_combos_held[key])
