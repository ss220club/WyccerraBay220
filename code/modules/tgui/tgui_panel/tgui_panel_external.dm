/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Fix chat"
	set category = "Special Verbs"
	var/action
	log_tgui(src, "Started fixing.")

	nuke_chat()

	// Failed to fix, using tgalert as fallback
	action = alert(src, "Did that work?", "Fix chat", "Yes", "No, switch to old ui")
	if(action == "No, switch to old ui")
		winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
		winset(src, "browseroutput", "is-disabled=1;is-visible=0")
		log_tgui(src, "Failed to fix.")

/client/proc/nuke_chat()
	// Catch all solution (kick the whole thing in the pants)
	winset(src, "output", "on-show=&is-disabled=0&is-visible=1")
	winset(src, "browseroutput", "is-disabled=1;is-visible=0")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing")
		tgui_panel = new(src)
	tgui_panel.initialize(force = TRUE)
	// Force show the panel to see if there are any errors
	winset(src, "output", "is-disabled=1&is-visible=0")
	winset(src, "browseroutput", "is-disabled=0;is-visible=1")

/client/verb/refresh_tgui()
	set name = "Refresh TGUI"
	set category = "Special Verbs"

	var/choice = alert(usr,
		"Используйте ТОЛЬКО если у вас проблема с TGUI.\
		Это интерфейсы с глазом слева-сверху.\
		В противном случае, вы можете получить белое окно, которое закроется только после перезахода!", "Refresh TGUI", "Refresh", "Cancel")
	if(choice != "Refresh")
		return
	var/refreshed_count = 0
	for(var/window_id in tgui_windows)
		var/datum/tgui_window/window = tgui_windows[window_id]
		if(!window.locked)
			window.acquire_lock()
			continue
		window.reinitialize()
		refreshed_count++
	to_chat(usr, SPAN_NOTICE("TGUI окон обновлено - [refreshed_count].<br>Если у вас появилось белое окно - переподключитесь, или откройте предыдущий TGUI интерфейс."))
