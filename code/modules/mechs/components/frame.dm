/obj/item/frame_holder
	matter = list(MATERIAL_STEEL = 175000, MATERIAL_PLASTIC = 50000, MATERIAL_OSMIUM = 30000)

/obj/item/frame_holder/Initialize(mapload, newloc)
	..()
	new /obj/structure/heavy_vehicle_frame(newloc)
	return  INITIALIZE_HINT_QDEL

/obj/structure/heavy_vehicle_frame
	name = "exosuit frame"
	desc = "The frame for an exosuit, apparently."
	icon = 'icons/mecha/mech_parts.dmi'
	icon_state = "backbone"
	density = TRUE
	pixel_x = -8
	atom_flags = ATOM_FLAG_CAN_BE_PAINTED

	// Holders for the final product.
	var/obj/item/mech_component/manipulators/arms
	var/obj/item/mech_component/propulsion/legs
	var/obj/item/mech_component/sensors/head
	var/obj/item/mech_component/chassis/body
	var/is_wired = 0
	var/is_reinforced = 0
	var/set_name
	dir = SOUTH

/obj/structure/heavy_vehicle_frame/set_color(new_colour)
	var/painted_component = FALSE
	for(var/obj/item/mech_component/comp in list(body, arms, legs, head))
		if(comp.set_color(new_colour))
			painted_component = TRUE
	if(painted_component)
		queue_icon_update()

/obj/structure/heavy_vehicle_frame/Destroy()
	QDEL_NULL(arms)
	QDEL_NULL(legs)
	QDEL_NULL(head)
	QDEL_NULL(body)
	. = ..()

/obj/structure/heavy_vehicle_frame/examine(mob/user)
	. = ..()
	if(!arms)
		to_chat(user, SPAN_WARNING("It is missing manipulators."))
	if(!legs)
		to_chat(user, SPAN_WARNING("It is missing propulsion."))
	if(!head)
		to_chat(user, SPAN_WARNING("It is missing sensors."))
	if(!body)
		to_chat(user, SPAN_WARNING("It is missing a chassis."))
	if(is_wired == FRAME_WIRED)
		to_chat(user, SPAN_WARNING("It has not had its wiring adjusted."))
	else if(!is_wired)
		to_chat(user, SPAN_WARNING("It has not yet been wired."))
	if(is_reinforced == FRAME_REINFORCED)
		to_chat(user, SPAN_WARNING("It has not had its internal reinforcement secured."))
	else if(is_reinforced == FRAME_REINFORCED_SECURE)
		to_chat(user, SPAN_WARNING("It has not had its internal reinforcement welded in."))
	else if(!is_reinforced)
		to_chat(user, SPAN_WARNING("It does not have any internal reinforcement."))

/obj/structure/heavy_vehicle_frame/on_update_icon()
	var/list/new_overlays = get_mech_images(list(legs, head, body, arms), layer)
	if(body)
		set_density(TRUE)
		AddOverlays(get_mech_image(null, "[body.icon_state]_cockpit", body.icon, body.color))
		if(body.pilot_coverage < 100 || body.transparent_cabin)
			new_overlays += get_mech_image(null, "[body.icon_state]_open_overlay", body.icon, body.color)
	else
		set_density(FALSE)
	SetOverlays(new_overlays)
	if(density != opacity)
		set_opacity(density)

/obj/structure/heavy_vehicle_frame/set_dir()
	..(SOUTH)

/obj/structure/heavy_vehicle_frame/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS

	// Remove reinforcement
	if(is_reinforced == FRAME_REINFORCED)
		user.visible_message(
			SPAN_NOTICE("[user] starts removing [src]'s reinforcements with [tool]."),
			SPAN_NOTICE("You start removing [src]'s reinforcements with [tool].")
		)
		if(!tool.use_as_tool(src, user, 0.5 SECONDS, volume = 50, skill_path = SKILL_DEVICES, do_flags = DO_REPAIR_CONSTRUCT) || is_reinforced != FRAME_REINFORCED)
			return
		material.place_sheet(loc, 10)
		material = null
		is_reinforced = FALSE
		user.visible_message(
			SPAN_NOTICE("[user] removes [src]'s reinforcements with [tool]."),
			SPAN_NOTICE("You remove [src]'s reinforcements with [tool].")
		)
		return

	// Remove component
	var/input = input(user, "Which component would you like to remove?", "[src] - Remove Component") as null|anything in list(arms, body, legs, head)
	if (!input || !user.use_sanity_check(src, tool) || !uninstall_component(input, user))
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	if (input == arms)
		arms = null
	else if (input == body)
		body = null
	else if (input == legs)
		legs = null
	else if (input == head)
		head = null
	update_icon()

/obj/structure/heavy_vehicle_frame/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	// Check for basic components.
	if (!(arms && legs && head && body))
		USE_FEEDBACK_FAILURE("[src] is still missing parts and cannot be completed.")
		return
	// Check for wiring.
	if (is_wired < FRAME_WIRED_ADJUSTED)
		if (is_wired == FRAME_WIRED)
			USE_FEEDBACK_FAILURE("[src]'s wiring needs to be adjusted before you can complete it.")
		else
			USE_FEEDBACK_FAILURE("[src] needs to be wired before you can complete it.")
		return
	// Check for basing metal internal plating.
	if (is_reinforced < FRAME_REINFORCED_WELDED)
		if (is_reinforced == FRAME_REINFORCED)
			USE_FEEDBACK_FAILURE("[src]'s internal reinforcement needs to be secured before you can complete it.")
		else if (is_reinforced == FRAME_REINFORCED_SECURE)
			USE_FEEDBACK_FAILURE("[src]'s internal reinforcement needs to be welded before you can complete it.")
		else
			USE_FEEDBACK_FAILURE("[src] needs internal reinforcement before you can complete it.")
		return
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] starts finishing [src] with [tool]."),
		SPAN_NOTICE("You start finishing [src] with [tool].")
	)
	if (!user.do_skilled((tool.toolspeed * 5) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
		return
	// Check for basic components.
	if (!(arms && legs && head && body))
		USE_FEEDBACK_FAILURE("[src] is still missing parts and cannot be completed.")
		return
	// Check for wiring.
	if (is_wired < FRAME_WIRED_ADJUSTED)
		if (is_wired == FRAME_WIRED)
			USE_FEEDBACK_FAILURE("[src]'s wiring needs to be adjusted before you can complete it.")
		else
			USE_FEEDBACK_FAILURE("[src] needs to be wired before you can complete it.")
		return
	// Check for basing metal internal plating.
	if (is_reinforced < FRAME_REINFORCED_WELDED)
		if (is_reinforced == FRAME_REINFORCED)
			USE_FEEDBACK_FAILURE("[src]'s internal reinforcement needs to be secured before you can complete it.")
		else if (is_reinforced == FRAME_REINFORCED_SECURE)
			USE_FEEDBACK_FAILURE("[src]'s internal reinforcement needs to be welded before you can complete it.")
		else
			USE_FEEDBACK_FAILURE("[src] needs internal reinforcement before you can complete it.")
		return
	var/mob/living/exosuit/exosuit = new(get_turf(src), src)
	transfer_fingerprints_to(exosuit)
	arms = null
	legs = null
	head = null
	body = null
	playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] finishes constructing [exosuit] with [tool]."),
		SPAN_NOTICE("You finish constructing [exosuit] with [tool].")
	)
	qdel(src)

/obj/structure/heavy_vehicle_frame/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if (!is_reinforced)
		USE_FEEDBACK_FAILURE("[src] has no reinforcements to secure or remove.")
		return
	if (is_reinforced == FRAME_REINFORCED_WELDED)
		USE_FEEDBACK_FAILURE("[src]'s internal reinforcements are welded in place and can't be removed.")
		return
	var/current_state = is_reinforced
	var/input
	if (is_reinforced == FRAME_REINFORCED_SECURE)
		input = "Remove Reinforcements"
	else
		input = input(user, "What would you like to do with the reinforcements?", "[src] - Reinforcements") as null|anything in list("Secure Reinforcements", "Remove Reinforcements")
		if (!input || !user.use_sanity_check(src, tool))
			return
		if (current_state != is_reinforced)
			USE_FEEDBACK_FAILURE("[src]'s state has changed.")
			return
	playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] starts [input == "Secure Reinforcements" ? "securing" : "removing"] [src]'s internal reinforcements with [tool]."),
		SPAN_NOTICE("You start [input == "Secure Reinforcements" ? "securing" : "removing"] [src]'s internal reinforcements with [tool].")
	)
	if (!user.do_skilled((tool.toolspeed * 4) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
		return
	if (current_state != is_reinforced)
		USE_FEEDBACK_FAILURE("[src]'s state has changed.")
		return
	playsound(src, 'sound/items/Ratchet.ogg', 50, TRUE)
	is_reinforced = input == "Secure Reinforcements" ? FRAME_REINFORCED_SECURE : FALSE
	if (input == "Remove Reinforcements")
		material.place_sheet(loc, 10)
		material = null
	update_icon()
	user.visible_message(
		SPAN_NOTICE("[user] [input == "Secure Reinforcements" ? "secures" : "removes"] [src]'s internal reinforcements with [tool]."),
		SPAN_NOTICE("You [input == "Secure Reinforcements" ? "secure" : "remove"] [src]'s internal reinforcements with [tool].")
	)

/obj/structure/heavy_vehicle_frame/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if (!is_wired)
		USE_FEEDBACK_FAILURE("[src] has no wiring to adjust or remove.")
		return
	var/input
	var/current_state = is_wired
	if (is_wired == FRAME_WIRED_ADJUSTED)
		input = "Remove Wiring"
	else
		input = input(user, "What would you like to do with the wiring?", "[src] - Wiring") as null|anything in list("Adjust Wiring", "Remove Wiring")
		if (!input || !user.use_sanity_check(src, tool))
			return
		if (is_wired != current_state)
			USE_FEEDBACK_FAILURE("[src]'s state has changed.")
			return
	playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] starts [input == "Adjust Wiring" ? "adjusting" : "removing"] the wiring in [src] with [tool]."),
		SPAN_NOTICE("You start [input == "Adjust Wiring" ? "adjusting" : "removing"] the wiring in [src] with [tool].")
	)
	if (!user.do_skilled((tool.toolspeed * 3) SECONDS, SKILL_ELECTRICAL, src) || !user.use_sanity_check(src, tool))
		return
	if (is_wired != current_state)
		USE_FEEDBACK_FAILURE("[src]'s state has changed.")
		return
	playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
	is_wired = input == "Adjust Wiring" ? FRAME_WIRED_ADJUSTED : FALSE
	update_icon()
	if (input == "Remove Wiring")
		new /obj/item/stack/cable_coil(loc, 10)
	user.visible_message(
		SPAN_NOTICE("[user] [input == "Adjust Wiring" ? "adjusts" : "removes"] the wiring in [src] with [tool]."),
		SPAN_NOTICE("You [input == "Adjust Wiring" ? "adjust" : "remove"] the wiring in [src] with [tool].")
	)

/obj/structure/heavy_vehicle_frame/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if (!is_reinforced)
		USE_FEEDBACK_FAILURE("[src] has no reinforcements to weld.")
		return
	if (is_reinforced == FRAME_REINFORCED)
		USE_FEEDBACK_FAILURE("[src]'s reinforcements need to be secured before you can weld them.")
		return
	var/obj/item/weldingtool/welder = tool
	if (!welder.can_use(1, user, "to weld [src]'s internal reinforcements"))
		return
	var/current_state = is_reinforced
	playsound(src, 'sound/items/Welder.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] starts [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]welding [src]'s internal reinforcements with [tool]."),
		SPAN_NOTICE("You start [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]welding [src]'s internal reinforcements with [tool]."),
		SPAN_ITALIC("You hear welding.")
	)
	if (!user.do_skilled((tool.toolspeed * 2) SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
		return
	if (!is_reinforced)
		USE_FEEDBACK_FAILURE("[src] has no reinforcements to weld.")
		return
	if (is_reinforced == FRAME_REINFORCED)
		USE_FEEDBACK_FAILURE("[src]'s reinforcements need to be secured before you can weld them.")
		return
	if (current_state != is_reinforced)
		USE_FEEDBACK_FAILURE("[src]'s state has changed.")
		return
	if (!welder.remove_fuel(1, user))
		return
	is_reinforced = is_reinforced == FRAME_REINFORCED_WELDED ? FRAME_REINFORCED_SECURE : FRAME_REINFORCED_WELDED
	update_icon()
	playsound(src, 'sound/items/Welder.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]welds [src]'s internal reinforcements with [tool]."),
		SPAN_NOTICE("You [is_reinforced == FRAME_REINFORCED_WELDED ? "un" : null]weld [src]'s internal reinforcements with [tool]."),
	)

/obj/structure/heavy_vehicle_frame/use_tool(obj/item/tool, mob/user, list/click_params)
	// Cable Coil - Install wiring
	if (isCoil(tool))
		if (is_wired)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		var/obj/item/stack/cable_coil/cable = tool
		if (!cable.can_use(10))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 10, "to wire [src].")
			return TRUE
		playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] starts wiring [src] with [tool]."),
			SPAN_NOTICE("You start wiring [src] with [tool].")
		)
		if (!user.do_skilled(3 SECONDS, SKILL_ELECTRICAL, src) || !user.use_sanity_check(src, tool))
			return TRUE
		if (is_wired)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		if (!cable.use(10))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 10, "to wire [src].")
			return TRUE
		playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
		is_wired = FRAME_WIRED
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] wires [src] with [tool]."),
			SPAN_NOTICE("You wires [src] with [tool].")
		)
		return TRUE

	// Material Stack - Install reinforcements
	if (istype(tool, /obj/item/stack/material))
		if (is_reinforced)
			USE_FEEDBACK_FAILURE("[src] already has internal reinforcements.")
			return TRUE
		var/obj/item/stack/material/stack = tool
		if (stack.reinf_material) // Current code doesn't account for reinforced materials
			USE_FEEDBACK_FAILURE("[stack] isn't suitable for [src].")
			return TRUE
		if (!stack.can_use(10))
			USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 10, "to reinforce [src].")
			return TRUE
		playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] starts reinforcing [src] with [tool]."),
			SPAN_NOTICE("You start reinforcing [src] with [tool].")
		)
		if (!user.do_skilled(3 SECONDS, SKILL_DEVICES, src) || !user.use_sanity_check(src, tool))
			return TRUE
		if (is_reinforced)
			USE_FEEDBACK_FAILURE("[src] already has internal reinforcements.")
			return TRUE
		if (!stack.use(10))
			USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 10, "to reinforce [src].")
			return TRUE
		playsound(src, 'sound/items/Deconstruct.ogg', 50, TRUE)
		material = stack.material
		is_reinforced = FRAME_REINFORCED
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] reinforces [src] with [tool]."),
			SPAN_NOTICE("You reinforce [src] with [tool].")
		)
		return TRUE

	// Mech Components - Install component
	if (istype(tool, /obj/item/mech_component/chassis))
		if (body)
			USE_FEEDBACK_FAILURE("[src] already has [body] installed.")
			return TRUE
		if (!install_component(tool, user))
			return TRUE
		body = tool
		update_icon()
		return TRUE
	if (istype(tool, /obj/item/mech_component/manipulators))
		if (arms)
			USE_FEEDBACK_FAILURE("[src] already has [arms.name] installed.")
			return TRUE
		if (!install_component(tool, user))
			return TRUE
		arms = tool
		update_icon()
		return TRUE
	if (istype(tool, /obj/item/mech_component/propulsion))
		if (legs)
			USE_FEEDBACK_FAILURE("[src] already has [legs.name] installed.")
			return TRUE
		if (!install_component(tool, user))
			return TRUE
		legs = tool
		update_icon()
		return TRUE
	if (istype(tool, /obj/item/mech_component/sensors))
		if (head)
			USE_FEEDBACK_FAILURE("[src] already has [head] installed.")
			return TRUE
		if (!install_component(tool, user))
			return TRUE
		head = tool
		update_icon()
		return TRUE

	return ..()


/obj/structure/heavy_vehicle_frame/proc/install_component(obj/item/thing, mob/user)
	var/obj/item/mech_component/MC = thing
	if(istype(MC) && !MC.ready_to_install())
		to_chat(user, SPAN_WARNING("[MC] [MC.gender == PLURAL ? "are" : "is"] not ready to install."))
		return 0
	if(user)
		visible_message(SPAN_NOTICE("[user] begins installing [thing] into [src]."))
		if(!user.canUnEquip(thing) || !do_after(user, 3 SECONDS * user.skill_delay_mult(SKILL_DEVICES), src, DO_PUBLIC_UNIQUE) || user.get_active_hand() != thing)
			return
		if(!user.unEquip(thing))
			return
	thing.forceMove(src)
	visible_message(SPAN_NOTICE("[user] installs [thing] into [src]."))
	playsound(user.loc, 'sound/machines/click.ogg', 50, 1)
	return 1

/obj/structure/heavy_vehicle_frame/proc/uninstall_component(obj/item/component, mob/user)
	if(!istype(component) || (component.loc != src) || !istype(user))
		return FALSE
	if(!do_after(user, 4 SECONDS * user.skill_delay_mult(SKILL_DEVICES), src, DO_PUBLIC_UNIQUE) || component.loc != src)
		return FALSE
	user.visible_message(SPAN_NOTICE("[user] crowbars [component] off [src]."))
	component.forceMove(get_turf(src))
	user.put_in_hands(component)
	playsound(user.loc, 'sound/items/Deconstruct.ogg', 50, 1)
	return TRUE
