/**
 * Creates a TGUI alert window and returns the user's response.
 *
 * This proc should be used to create alerts that the caller will wait for a response from.
 * Arguments:
 * * user - The user to show the alert to.
 * * message - The content of the alert, shown in the body of the TGUI window.
 * * title - The of the alert modal, shown on the top of the TGUI window.
 * * buttons - The options that can be chosen by the user, each string is assigned a button on the UI.
 * * timeout - The timeout of the alert, after which the modal will close and qdel itself. Set to zero for no timeout.
 * * autofocus - The bool that controls if this alert should grab window focus.
 */
/proc/tgui_alert(mob/user, message = "", title = "Alert", list/buttons = list("Ok"), timeout = 0, autofocus = TRUE, tgui_state = GLOB.tgui_always_state)
	if(!user)
		user = usr

	if(!istype(user))
		if(!isclient(user))
			CRASH("We passed something that wasn't a user/client in a TGUI Alert! The passed user was [user]!")
		var/client/client = user
		user = client.mob

	if(isnull(user.client))
		return

	// A gentle nudge - you should not be using TGUI alert for anything other than a simple message.
	if(length(buttons) > 3)
		log_tgui(user, "Error: TGUI Alert initiated with too many buttons. Use a list.", "TguiAlert")
		return tgui_input_list(user, message, title, buttons, timeout)

	// Client does NOT have tgui_input on: Returns regular input
	if(user.get_preference_value(/datum/client_preference/tgui_input) == GLOB.PREF_NO)
		if(length(buttons) == 2)
			return alert(user, message, title, buttons[1], buttons[2])
		if(length(buttons) == 3)
			return alert(user, message, title, buttons[1], buttons[2], buttons[3])

	var/datum/tgui_alert/alert = new(user, message, title, buttons, timeout, autofocus, tgui_state)

	alert.tgui_interact(user)
	alert.wait()
	if(alert)
		. = alert.choice
		qdel(alert)

/**
 * # tgui_alert
 *
 * Datum used for instantiating and using a TGUI-controlled modal that prompts the user with
 * a message and has buttons for responses.
 */
/datum/tgui_alert
	/// The title of the TGUI window
	var/title
	/// The textual body of the TGUI window
	var/message
	/// The list of buttons (responses) provided on the TGUI window
	var/list/buttons
	/// The button that the user has pressed, null if no selection has been made
	var/choice
	/// The time at which the tgui_alert was created, for displaying timeout progress.
	var/start_time
	/// The lifespan of the tgui_alert, after which the window will close and delete itself.
	var/timeout
	/// The bool that controls if this modal should grab window focus
	var/autofocus
	/// Boolean field describing if the tgui_alert was closed by the user.
	var/closed
	/// The TGUI UI state that will be returned in ui_state(). Default: always_state
	var/datum/tgui_state/state

/datum/tgui_alert/New(mob/user, message, title, list/buttons, timeout, autofocus, tgui_state)
	src.autofocus = autofocus
	src.buttons = buttons.Copy()
	src.message = message
	src.title = title
	src.state = tgui_state

	if(timeout)
		src.timeout = timeout
		start_time = world.time
		QDEL_IN(src, timeout)

/datum/tgui_alert/Destroy(force)
	SStgui.close_uis(src)
	state = null
	QDEL_NULL(buttons)
	return ..()

/**
 * Waits for a user's response to the tgui_alert's prompt before returning. Returns early if
 * the window was closed by the user.
 */
/datum/tgui_alert/proc/wait()
	while(!choice && !closed && !QDELETED(src))
		stoplag(1)

/datum/tgui_alert/tgui_state(mob/user)
	return state

/datum/tgui_alert/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AlertModal")
		ui.open()

/datum/tgui_alert/tgui_close(mob/user)
	closed = TRUE

/datum/tgui_alert/tgui_static_data(mob/user)
	var/list/data = list()
	data["autofocus"] = autofocus
	data["buttons"] = buttons
	data["message"] = message
	data["large_buttons"] = user.get_preference_value(/datum/client_preference/tgui_input_large)
	data["swapped_buttons"] = user.get_preference_value(/datum/client_preference/tgui_input_swap)
	data["title"] = title
	return data

/datum/tgui_alert/tgui_data(mob/user)
	var/list/data = list()
	if(timeout)
		data["timeout"] = CLAMP01((timeout - (world.time - start_time) - 1 SECONDS) / (timeout - 1 SECONDS))
	return data

/datum/tgui_alert/tgui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("choose")
			if(!(params["choice"] in buttons))
				CRASH("[usr] entered a non-existent button choice: [params["choice"]]")
			set_choice(params["choice"])
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE
		if("cancel")
			closed = TRUE
			SStgui.close_uis(src)
			return TRUE

/datum/tgui_alert/proc/set_choice(choice)
	src.choice = choice
