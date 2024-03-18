/obj/structure/firedoor_assembly
	name = "emergency shutter assembly"
	desc = "It can save lives."
	icon = 'icons/obj/doors/hazard/door.dmi'
	icon_state = "construction"
	anchored = FALSE
	opacity = 0
	density = TRUE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/wired = 0

/obj/structure/firedoor_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!wired)
		USE_FEEDBACK_FAILURE("[src] has no wires to cut.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts cutting [src]'s wires with [tool]."),
		SPAN_NOTICE("You start cutting [src]'s wires with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || !wired)
		return
	new /obj/item/stack/cable_coil(loc, 1)
	wired = FALSE
	user.visible_message(
		SPAN_NOTICE("[user] cuts [src]'s wires with [tool]."),
		SPAN_NOTICE("You cut [src]'s wires with [tool].")
	)

/obj/structure/firedoor_assembly/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(anchored)
		USE_FEEDBACK_NEED_UNANCHOR(user)
		return
	if(!tool.tool_start_check(user, 1))
		return
	USE_FEEDBACK_DECONSTRUCT_START(user)
	if(!tool.use_as_tool(src, user, 4 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	var/obj/item/stack/material/steel/stack = new (loc, 4)
	transfer_fingerprints_to(stack)
	user.visible_message(
		SPAN_NOTICE("[user] dismantles [src] with [tool]."),
		SPAN_NOTICE("You dismantle [src] with [tool].")
	)
	qdel(src)

/obj/structure/firedoor_assembly/use_tool(obj/item/tool, mob/user, list/click_params)
	// Air Alarm Electronics - Install circuit
	if (istype(tool, /obj/item/airalarm_electronics))
		if (!wired)
			USE_FEEDBACK_FAILURE("[src] needs to be wired before you can install [tool].")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
		var/obj/machinery/door/firedoor/new_door = new(loc)
		new_door.hatch_open = TRUE
		new_door.close()
		transfer_fingerprints_to(new_door)
		user.visible_message(
			SPAN_NOTICE("[user] installs [tool] into [src]."),
			SPAN_NOTICE("You install [tool] into [src].")
		)
		qdel(tool)
		qdel_self()
		return TRUE

	// Cable Coil - Wire the assembly
	if (isCoil(tool))
		if (wired)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		if (!anchored)
			USE_FEEDBACK_FAILURE("[src] needs to be anchored before you can wire it.")
			return TRUE
		var/obj/item/stack/cable_coil/cable = tool
		if (!cable.can_use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 1, "to wire [src].")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] starts wiring [src] with [cable.get_vague_name(FALSE)]."),
			SPAN_NOTICE("You start wiring [src] with [cable.get_exact_name(1)].")
		)
		if (!user.do_skilled(4 SECONDS, SKILL_ELECTRICAL, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return TRUE
		if (wired)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		if (!anchored)
			USE_FEEDBACK_FAILURE("[src] needs to be anchored before you can wire it.")
			return TRUE
		if (!cable.can_use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 1, "to wire [src].")
			return TRUE
		wired = TRUE
		user.visible_message(
			SPAN_NOTICE("[user] wires [src] with [cable.get_vague_name(FALSE)]."),
			SPAN_NOTICE("You wire [src] with [cable.get_exact_name(1)].")
		)
		return TRUE

	return ..()
