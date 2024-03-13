/obj/machinery/barrier
	name = "deployable barrier"
	desc = "A deployable barrier."
	icon = 'icons/obj/security_barriers.dmi'
	icon_state = "barrier0"
	req_access = list(access_brig)
	density = TRUE
	health_max = 200
	health_min_damage = 7

	var/locked = FALSE

/obj/machinery/barrier/on_update_icon()
	icon_state = "barrier[locked]"

/obj/machinery/barrier/examine(mob/user, distance)
	. = ..()
	if (locked)
		var/message = "The lights show it is locked onto [get_turf(src)]."
		if (emagged && distance < 3)
			message += SPAN_WARNING(" The locking clamps have other ideas.")
		to_chat(user, message)

/obj/machinery/barrier/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!emagged)
		balloon_alert(user, "фиксаторы не повреждены")
		return
	if(!tool.tool_start_check(user, 1))
		return
	balloon_alert(user, "ремонт")
	if(!tool.use_as_tool(src, user, 15 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	emagged = FALSE
	USE_FEEDBACK_REPAIR_GENERAL
	if(locked)
		visible_message(
			"[src]'s clamps engage, locking onto [get_turf(src)].",
			"You hear metal sliding and creaking.",
			range = 5
		)
		anchored = TRUE
	update_icon()

/obj/machinery/barrier/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(isid(I))
		var/success = allowed(user)
		var/message = " to no effect"
		if(success)
			if(locked)
				message = ", unlocking it from [get_turf(src)]"
			else
				message = ", locking it onto [get_turf(src)]"
		user.visible_message(
			"[user] swipes \an [I] against [src].",
			"You swipe [I] against [src][message].",
			"You hear metal sliding and creaking.",
			range = 5
		)
		if(success)
			locked = !locked
			anchored = emagged ? FALSE : locked
			update_icon()
		return TRUE
	return ..()

/obj/machinery/barrier/emag_act(remaining_charges, mob/user, emag_source)
	if (user)
		var/message = emagged ? "achieving nothing new" : "fusing the locking clamps open"
		user.visible_message(
			"[user] swipes \an [emag_source] against [src].",
			"You swipe [emag_source] against [src], [message].",
			range = 5
		)
	if (emagged)
		return
	anchored = FALSE
	emagged = TRUE
	return 1

/obj/machinery/barrier/emp_act(severity)
	SHOULD_CALL_PARENT(FALSE)
	if (severity > EMP_ACT_LIGHT)
		return
	locked = FALSE
	anchored = emagged ? FALSE : locked
	update_icon()
	if (severity > EMP_ACT_HEAVY)
		return
	sparks(3, 1, src)
	GLOB.empd_event.raise_event(src, severity)
	emag_act()

/obj/machinery/barrier/on_death()
	if (QDELETED(src))
		return
	var/turf/T = get_turf(src)
	qdel(src)
	new /obj/item/stack/material/rods(T, rand(1, 4))
	new /obj/item/stack/material/steel(T, rand(1, 4))
	explosion(T, 2, EX_ACT_LIGHT)
	sparks(3, 1, T)
