/datum/preferences
	/// Custom Keybindings
	var/list/key_bindings = list()
	var/hotkeys = TRUE

/datum/category_group/player_setup_category/controls
	name = "Controls"
	sort_order = 9
	category_item_type = /datum/category_item/player_setup_item/controls

/datum/category_item/player_setup_item/controls/keybindings
	name = "Keybindings"
	sort_order = 1

/datum/category_item/player_setup_item/controls/keybindings/load_preferences(datum/pref_record_reader/R)
	pref.key_bindings = R.read("key_bindings")

/datum/category_item/player_setup_item/controls/keybindings/sanitize_preferences()
	pref.key_bindings = sanitize_keybindings(pref.key_bindings)
	pref.check_keybindings()

/datum/category_item/player_setup_item/controls/keybindings/save_preferences(datum/pref_record_writer/W)
	W.write("key_bindings", pref.key_bindings)

/datum/category_item/player_setup_item/controls/keybindings/content(mob/user)
	. = list()
	// Create an inverted list of keybindings -> key
	var/list/user_binds = list()
	for (var/key in pref.key_bindings)
		for(var/kb_name in pref.key_bindings[key])
			user_binds[kb_name] += list(key)

	var/list/kb_categories = list()
	// Group keybinds by category
	for (var/name in GLOB.keybindings_by_name)
		var/datum/keybinding/kb = GLOB.keybindings_by_name[name]
		kb_categories[kb.category] += list(kb)

	. += "<center>"
	. += "<div class='statusDisplay'>"
	for (var/category in kb_categories)
		. += "<h3>[category]</h3>"
		. += "<table width='100%'>"
		for (var/i in kb_categories[category])
			var/datum/keybinding/kb = i
			if(!length(user_binds[kb.name]) || (user_binds[kb.name][1] == "None" && length(user_binds[kb.name]) == 1))
				. += "<tr><td width='40%'>[kb.full_name]</td><td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name];old_key=["None"]'>None</a></td>"
				var/list/default_keys = pref.hotkeys ? kb.hotkey_keys : kb.classic_keys
				var/class
				if(user_binds[kb.name] ~= default_keys)
					class = "class='linkOff fluid'"
				else
					class = "class='fluid' href ='?src=\ref[src];preference=keybinding_reset;keybinding=[kb.name];old_keys=[jointext(user_binds[kb.name], ",")]"

				. += {"<td width='15%'></td><td width='15%'></td><td width='15%'><a [class]'>Reset</a></td>"}
				. += "</tr>"
			else
				var/bound_key = user_binds[kb.name][1]
				var/normal_name = GLOB.keybindings_map_reverse[bound_key] ? GLOB.keybindings_map[bound_key] : bound_key
				. += "<tr><td width='40%'>[kb.full_name]</td><td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[pretty_keybinding_name(normal_name)]</a></td>"
				for(var/bound_key_index in 2 to length(user_binds[kb.name]))
					bound_key = user_binds[kb.name][bound_key_index]
					normal_name = GLOB.keybindings_map_reverse[bound_key] ? GLOB.keybindings_map_reverse[bound_key] : bound_key
					. += "<td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name];old_key=[bound_key]'>[pretty_keybinding_name(normal_name)]</a></td>"
				if(length(user_binds[kb.name]) < MAX_KEYS_PER_KEYBIND)
					. += "<td width='15%'><a class='fluid' href ='?src=\ref[src];preference=keybindings_capture;keybinding=[kb.name]'>None</a></td>"
				for(var/j in 1 to MAX_KEYS_PER_KEYBIND - (length(user_binds[kb.name]) + 1))
					. += "<td width='15%'></td>"
				var/list/default_keys = pref.hotkeys ? kb.hotkey_keys : kb.classic_keys
				. += {"<td width='15%'><a [user_binds[kb.name] ~= default_keys ? "class='linkOff fluid'" : "class='fluid' href ='?src=\ref[src];preference=keybinding_reset;keybinding=[kb.name];old_keys=[jointext(user_binds[kb.name], ",")]"]'>Reset</a></td>"}
				. += "</tr>"
		. += "</table>"

	. += "</div>"
	. += "<br><br>"
	. += "<a href ='?src=\ref[src];preference=keybindings_reset'>Reset to default</a>"
	. += "</center>"

	return jointext(., null)

/datum/category_item/player_setup_item/controls/keybindings/OnTopic(href, list/href_list, mob/user)
	switch(href_list["preference"])
		if("keybindings_capture")
			var/datum/keybinding/kb = GLOB.keybindings_by_name[href_list["keybinding"]]
			var/old_key = href_list["old_key"]
			capture_keybinding(user, kb, old_key)
			return TOPIC_REFRESH

		if("keybindings_set")
			var/kb_name = href_list["keybinding"]
			if(!kb_name)
				close_browser(user, "window=capturekeypress")
				return TOPIC_REFRESH

			var/clear_key = text2num(href_list["clear_key"])
			var/old_key = href_list["old_key"]
			if(clear_key)
				if(pref.key_bindings[old_key])
					pref.key_bindings[old_key] -= kb_name
					if(!(kb_name in pref.key_bindings["None"]))
						LAZYADD(pref.key_bindings["None"], kb_name)
					if(!length(pref.key_bindings[old_key]))
						pref.key_bindings -= old_key
				close_browser(user, "window=capturekeypress")
				user.client.set_macros()
				return TOPIC_REFRESH

			var/new_key = uppertext(href_list["key"])
			var/AltMod = text2num(href_list[ALT_CLICK]) ? "Alt" : ""
			var/CtrlMod = text2num(href_list[CTRL_CLICK]) ? "Ctrl" : ""
			var/ShiftMod = text2num(href_list[SHIFT_CLICK]) ? "Shift" : ""
			var/numpad = text2num(href_list["numpad"]) ? "Numpad" : ""

			if(!new_key) // Just in case (; - not work although keyCode 186 and nothing should break)
				close_browser(user, "window=capturekeypress")
				return TOPIC_REFRESH

			if(GLOB.keybindings_map[new_key])
				new_key = GLOB.keybindings_map[new_key]

			var/full_key
			switch(new_key)
				if("Alt")
					full_key = "[new_key][CtrlMod][ShiftMod]"
				if("Ctrl")
					full_key = "[AltMod][new_key][ShiftMod]"
				if("Shift")
					full_key = "[AltMod][CtrlMod][new_key]"
				else
					full_key = "[AltMod][CtrlMod][ShiftMod][numpad][new_key]"
			if(kb_name in pref.key_bindings[full_key]) //We pressed the same key combination that was already bound here, so let's remove to re-add and re-sort.
				pref.key_bindings[full_key] -= kb_name
			if(pref.key_bindings[old_key])
				pref.key_bindings[old_key] -= kb_name
				if(!length(pref.key_bindings[old_key]))
					pref.key_bindings -= old_key
			pref.key_bindings[full_key] += list(kb_name)
			pref.key_bindings[full_key] = sortTim(pref.key_bindings[full_key], GLOBAL_PROC_REF(cmp_text_asc))

			close_browser(user, "window=capturekeypress")
			user.client.set_macros()
			return TOPIC_REFRESH

		if("keybindings_reset")
			pref.key_bindings = deepCopyList(GLOB.hotkey_keybinding_list_by_key)
			user.client.set_macros()
			return TOPIC_REFRESH

		if("keybinding_reset")
			var/kb_name = href_list["keybinding"]
			var/list/old_keys = splittext(href_list["old_keys"], ",")

			for(var/old_key in old_keys)
				if(!pref.key_bindings[old_key])
					continue
				pref.key_bindings[old_key] -= kb_name
				if(!length(pref.key_bindings[old_key]))
					pref.key_bindings -= old_key

			var/datum/keybinding/kb = GLOB.keybindings_by_name[kb_name]
			for(var/key in kb.hotkey_keys)
				pref.key_bindings[key] += list(kb_name)
				pref.key_bindings[key] = sortTim(pref.key_bindings[key], GLOBAL_PROC_REF(cmp_text_asc))
			user.client.set_macros()
			return TOPIC_REFRESH

	return ..()
