/**
 * tgui state: default_state
 *
 * Checks a number of things -- mostly physical distance for humans and view for robots.
 */

GLOBAL_DATUM_INIT(tgui_default_state, /datum/tgui_state/default, new)

/datum/tgui_state/default/can_use_topic(src_object, mob/user)
	return user.default_can_use_tgui_topic(src_object) // Call the individual mob-overridden procs.

/mob/proc/default_can_use_tgui_topic(src_object)
	return STATUS_CLOSE // Don't allow interaction by default.

/mob/living/default_can_use_tgui_topic(src_object)
	. = shared_tgui_interaction(src_object)
	if(. > STATUS_CLOSE && loc)
		. = min(., loc.contents_tgui_distance(src_object, src)) // Check the distance...
	if(. == STATUS_INTERACTIVE) // Non-human living mobs can only look, not touch.
		return STATUS_UPDATE

/mob/living/carbon/human/default_can_use_tgui_topic(src_object)
	. = shared_tgui_interaction(src_object)
	if(. > STATUS_CLOSE)
		. = min(., shared_living_tgui_distance(src_object)) // Check the distance...

/mob/living/silicon/robot/default_can_use_tgui_topic(src_object)
	. = shared_tgui_interaction(src_object)
	if(. <= STATUS_DISABLED)
		return

	// Robots can interact with anything they can see.
	if((src_object in view(src)) && (get_dist(src, src_object) <= get_lesser_view_size_component(client.view)))
		return STATUS_INTERACTIVE
	return STATUS_DISABLED // Otherwise they can keep the UI open.

/mob/living/silicon/ai/default_can_use_tgui_topic(src_object)
	. = shared_tgui_interaction(src_object)
	if(. < STATUS_INTERACTIVE)
		return

	// The AI can interact with anything it can see nearby, or with cameras while wireless control is enabled.
	var/can_see = (src_object in view(client.view, src))
	if(!can_see)
		if(is_in_chassis())
			can_see = GLOB.cameranet && GLOB.cameranet.is_turf_visible(get_turf(src_object))
		else
			can_see = get_dist(src_object, src) <= get_lesser_view_size_component(client.view)

	if(!control_disabled && can_see)
		return STATUS_INTERACTIVE
	return STATUS_CLOSE

/mob/living/simple_animal/default_can_use_tgui_topic(src_object)
	. = shared_tgui_interaction(src_object)
	if(. > STATUS_CLOSE)
		. = min(., shared_living_tgui_distance(src_object)) //simple animals can only use things they're near.

/mob/living/silicon/pai/default_can_use_tgui_topic(src_object)
	// pAIs can only use themselves and the owner's radio.
	if((src_object == src || src_object == silicon_radio) && !stat)
		return STATUS_INTERACTIVE
	else
		return ..()

/mob/observer/ghost/default_can_use_tgui_topic()
	if(can_admin_interact())
		return STATUS_INTERACTIVE				// Admins are more equal
	return STATUS_UPDATE						// Ghosts can view updates
