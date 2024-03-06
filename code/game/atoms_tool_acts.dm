/**
 * ## Item interaction
 *
 * Handles non-combat iteractions of a tool on this atom,
 * such as using a tool on a wall to deconstruct it,
 * or scanning someone with a health analyzer
 *
 * This can be overridden to add custom item interactions to this atom
 *
 * Do not call this directly
 */
/atom/proc/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	var/early_sig_return = NONE
	early_sig_return = SEND_SIGNAL(src, COMSIG_ATOM_ITEM_INTERACTION, user, tool, modifiers) \
		| SEND_SIGNAL(tool, COMSIG_ITEM_INTERACTING_WITH_ATOM, user, src, modifiers)
	if(early_sig_return)
		return early_sig_return

	var/interact_return = tool.interact_with_atom(src, user)
	if(interact_return)
		return interact_return

	var/tool_type = tool.tool_behaviour
	if(!tool_type) // here on only deals with ... tools
		return NONE

	var/signal_result = SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT(tool_type), user, tool)
	if(signal_result)
		return signal_result

	if(QDELETED(tool))
		return ITEM_INTERACT_SUCCESS // Safe-ish to assume that if we deleted our item something succeeded

	var/act_result = NONE // or FALSE, or null, as some things may return

	switch(tool_type)
		if(TOOL_CROWBAR)
			act_result = crowbar_act(user, tool)
		if(TOOL_MULTITOOL)
			act_result = multitool_act(user, tool)
		if(TOOL_SCREWDRIVER)
			act_result = screwdriver_act(user, tool)
		if(TOOL_WRENCH)
			act_result = wrench_act(user, tool)
		if(TOOL_WIRECUTTER)
			act_result = wirecutter_act(user, tool)
		if(TOOL_WELDER)
			act_result = welder_act(user, tool)
		if(TOOL_ANALYZER)
			act_result = analyzer_act(user, tool)

	if(!act_result)
		var/signal_post_act = SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT_EMPTY, user, tool)
		if(signal_post_act)
			return signal_post_act

	SEND_SIGNAL(src, COMSIG_ATOM_TOOL_ACT_RESULT(tool_type), user, tool, act_result)

	if(!act_result)
		return NONE

	// A tooltype_act has completed successfully
	log_game()
	log_tool("[key_name(user)] used [tool] on [src] at [x], [y], [z]")
	SEND_SIGNAL(tool, COMSIG_TOOL_ATOM_ACTED_PRIMARY(tool_type), src)
	return act_result

/**
 * Called when this item is being used to interact with an atom,
 * IE, a mob is clicking on an atom with this item.
 *
 * Return an ITEM_INTERACT_ flag in the event the interaction was handled, to cancel further interaction code.
 * Return NONE to allow default interaction / tool handling.
 */
/obj/item/proc/interact_with_atom(atom/interacting_with, mob/living/user)
	return NONE

/*
 * Tool-specific behavior procs.
 *
 * Return an ITEM_INTERACT_ flag to handle the event, or NONE to allow the mob to attack the atom.
 * Returning TRUE will also cancel attacks. It is equivalent to an ITEM_INTERACT_ flag. (This is legacy behavior, and is not to be relied on)
 * Returning FALSE or null will also allow the mob to attack the atom. (This is also legacy behavior)
 */

/// Called on an object when a tool with crowbar capabilities is used to left click an object
/atom/proc/crowbar_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with multitool capabilities is used to left click an object
/atom/proc/multitool_act(mob/living/user, obj/item/tool)
	return

///Check if an item supports a data buffer (is a multitool)
/atom/proc/multitool_check_buffer(user, obj/item/device/multitool, silent = FALSE)
	if(!istype(multitool, /obj/item/device/multitool))
		if(user && !silent)
			to_chat(user, SPAN_WARNING("[multitool] has no data buffer!"))
		return FALSE
	return TRUE

/// Called on an object when a tool with screwdriver capabilities is used to left click an object
/atom/proc/screwdriver_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wrench capabilities is used to left click an object
/atom/proc/wrench_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with wirecutter capabilities is used to left click an object
/atom/proc/wirecutter_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with welder capabilities is used to left click an object
/atom/proc/welder_act(mob/living/user, obj/item/tool)
	return

/// Called on an object when a tool with analyzer capabilities is used to left click an object
/atom/proc/analyzer_act(mob/living/user, obj/item/tool)
	return
