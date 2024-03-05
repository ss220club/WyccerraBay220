/obj/structure/door_assembly
	name = "airlock assembly"
	icon = 'icons/obj/doors/station/door.dmi'
	icon_state = "construction"
	anchored = FALSE
	density = TRUE
	w_class = ITEM_SIZE_NO_CONTAINER
	obj_flags = OBJ_FLAG_ANCHORABLE

	var/const/ASSEMBLY_STATE_FRAME = 0
	var/const/ASSEMBLY_STATE_WIRED = 1
	var/const/ASSEMBLY_STATE_CIRCUIT = 2
	var/state = ASSEMBLY_STATE_FRAME

	var/static/list/reinforcement_materials = list(
		MATERIAL_GOLD,
		MATERIAL_SILVER,
		MATERIAL_DIAMOND,
		MATERIAL_URANIUM,
		MATERIAL_PHORON,
		MATERIAL_SANDSTONE
	)

	var/base_icon_state = ""
	var/base_name = "Airlock"
	var/obj/item/airlock_electronics/electronics = null
	var/airlock_type = /obj/machinery/door/airlock //the type path of the airlock once completed
	var/glass_type = /obj/machinery/door/airlock/glass
	var/glass = 0 // 0 = glass can be installed. -1 = glass can't be installed. 1 = glass is already installed. Text = mineral plating is installed instead.
	var/created_name = null
	var/panel_icon = 'icons/obj/doors/station/panel.dmi'
	var/fill_icon = 'icons/obj/doors/station/fill_steel.dmi'
	var/glass_icon = 'icons/obj/doors/station/fill_glass.dmi'
	var/paintable = AIRLOCK_PAINTABLE_MAIN|AIRLOCK_PAINTABLE_STRIPE
	var/door_color = "none"
	var/stripe_color = "none"
	var/symbol_color = "none"


/obj/structure/door_assembly/Initialize()
	. = ..()
	update_state()


/obj/structure/door_assembly/door_assembly_hatch
	icon = 'icons/obj/doors/hatch/door.dmi'
	panel_icon = 'icons/obj/doors/hatch/panel.dmi'
	fill_icon = 'icons/obj/doors/hatch/fill_steel.dmi'
	base_name = "Airtight Hatch"
	airlock_type = /obj/machinery/door/airlock/hatch
	glass = -1

/obj/structure/door_assembly/door_assembly_highsecurity // Borrowing this until WJohnston makes sprites for the assembly
	icon = 'icons/obj/doors/secure/door.dmi'
	fill_icon = 'icons/obj/doors/secure/fill_steel.dmi'
	base_name = "High Security Airlock"
	airlock_type = /obj/machinery/door/airlock/highsecurity
	glass = -1
	paintable = 0

/obj/structure/door_assembly/door_assembly_ext
	icon = 'icons/obj/doors/external/door.dmi'
	fill_icon = 'icons/obj/doors/external/fill_steel.dmi'
	glass_icon = 'icons/obj/doors/external/fill_glass.dmi'
	base_name = "External Airlock"
	airlock_type = /obj/machinery/door/airlock/external
	glass_type = /obj/machinery/door/airlock/external/glass
	paintable = 0

/obj/structure/door_assembly/multi_tile
	icon = 'icons/obj/doors/double/door.dmi'
	fill_icon = 'icons/obj/doors/double/fill_steel.dmi'
	glass_icon = 'icons/obj/doors/double/fill_glass.dmi'
	panel_icon = 'icons/obj/doors/double/panel.dmi'
	dir = EAST
	var/width = 1
	airlock_type = /obj/machinery/door/airlock/multi_tile
	glass_type = /obj/machinery/door/airlock/multi_tile/glass


/obj/structure/door_assembly/multi_tile/Initialize()
	. = ..()
	if(dir in list(EAST, WEST))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size
	update_state()


/obj/structure/door_assembly/multi_tile/Move()
	. = ..()
	if(dir in list(EAST, WEST))
		bound_width = width * world.icon_size
		bound_height = world.icon_size
	else
		bound_width = world.icon_size
		bound_height = width * world.icon_size


/obj/structure/door_assembly/can_anchor(obj/item/tool, mob/user, silent)
	. = ..()
	if (!.)
		return
	if (state != ASSEMBLY_STATE_FRAME)
		if (!silent)
			USE_FEEDBACK_FAILURE("[src] needs its components and wiring removed before you can unanchor it.")
		return FALSE

/obj/structure/door_assembly/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!electronics)
		USE_FEEDBACK_FAILURE("[src] has no circuit to remove.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts removing [src]'s [electronics.name] with [tool]."),
		SPAN_NOTICE("You start removing [src]'s [electronics.name] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || !electronics)
		return
	electronics.dropInto(loc)
	electronics.add_fingerprint(user)
	state = ASSEMBLY_STATE_WIRED
	update_state()
	electronics = null
	user.visible_message(
		SPAN_NOTICE("[user] removes [src]'s [electronics.name] with [tool]."),
		SPAN_NOTICE("You remove [src]'s [electronics.name] with [tool].")
	)

/obj/structure/door_assembly/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(state != ASSEMBLY_STATE_CIRCUIT)
		USE_FEEDBACK_FAILURE("[src] needs a circuit before you can finish it.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts finishing [src] with [tool]."),
		SPAN_NOTICE("You start finishing [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 5 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || state != ASSEMBLY_STATE_CIRCUIT)
		return
	var/path
	if(istext(glass))
		path = text2path("/obj/machinery/door/airlock/[glass]")
	else if(glass == 1)
		path = glass_type
	else
		path = airlock_type
	var/obj/machinery/door/airlock/airlock = new path(loc, src)
	transfer_fingerprints_to(airlock)
	airlock.add_fingerprint(user, tool = tool)
	user.visible_message(
		SPAN_NOTICE("[user] finishes [airlock] with [tool]."),
		SPAN_NOTICE("You finishes [airlock] with [tool].")
	)
	qdel(src)

/obj/structure/door_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(state < ASSEMBLY_STATE_WIRED)
		USE_FEEDBACK_FAILURE("[src] has no wiring to remove.")
		return
	if(state > ASSEMBLY_STATE_WIRED)
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts cutting [src]'s wires with [tool]."),
		SPAN_NOTICE("You start cutting [src]'s wires with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_ELECTRICAL, do_flags = DO_REPAIR_CONSTRUCT) || state != ASSEMBLY_STATE_WIRED)
		return
	var/obj/item/stack/cable_coil/cable = new(loc, 1)
	cable.add_fingerprint(user, tool = tool)
	state = ASSEMBLY_STATE_FRAME
	update_state()
	user.visible_message(
		SPAN_NOTICE("[user] cuts [src]'s wires with [tool]."),
		SPAN_NOTICE("You cut [src]'s wires with [tool].")
	)

/obj/structure/door_assembly/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	// Remove glass/plating
	if(glass)
		var/glass_noun = istext(glass) ? "[glass] plating" : "glass panel"
		var/obj/item/weldingtool/welder = tool
		if(!welder.can_use(1, user, "to remove [src]'s [glass_noun]."))
			return
		playsound(src, 'sound/items/Welder2.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] starts welding [src]'s [glass_noun] off with [tool]."),
			SPAN_NOTICE("You start welding [src]'s [glass_noun] off with [tool].")
		)
		if(!user.do_skilled((tool.toolspeed * 4) SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return
		if(!glass)
			USE_FEEDBACK_FAILURE("[src]'s state has changed.")
			return
		if(!welder.remove_fuel(1, user))
			return
		var/obj/item/stack/material/stack
		if(istext(glass))
			var/path = text2path("/obj/item/stack/material/[glass]")
			stack = new path(loc, 2)
		else
			stack = new /obj/item/stack/material/glass/reinforced(loc)
		stack.add_fingerprint(user, tool = tool)
		glass = null
		update_state()
		playsound(src, 'sound/items/Welder2.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] welds [src]'s [glass_noun] off with [tool]."),
			SPAN_NOTICE("You weld [src]'s [glass_noun] off with [tool].")
		)
		return
	// Dismantle assembly
	if(anchored)
		USE_FEEDBACK_FAILURE("[src] must be unanchored before you can dismantle it.")
		return
	var/obj/item/weldingtool/welder = tool
	if(!welder.can_use(1, user, "to dismantle [src]."))
		return
	playsound(src, 'sound/items/Welder2.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] starts dismantling [src] with [tool]."),
		SPAN_NOTICE("You start dismantling [src] with [tool].")
	)
	if(!user.do_skilled((tool.toolspeed * 4) SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
		return
	if(anchored)
		USE_FEEDBACK_FAILURE("[src] must be unanchored before you can dismantle it.")
		return
	if(!welder.remove_fuel(1, user))
		return
	var/obj/item/stack/material/steel/stack = new(loc, 4)
	transfer_fingerprints_to(stack)
	stack.add_fingerprint(user, tool = tool)
	playsound(src, 'sound/items/Welder2.ogg', 50, TRUE)
	user.visible_message(
		SPAN_NOTICE("[user] dismantles [src] with [tool]."),
		SPAN_NOTICE("You dismantle [src] with [tool].")
	)
	qdel(src)

/obj/structure/door_assembly/use_tool(obj/item/tool, mob/user, list/click_params)
	// Airlock Electronics - Install circuit
	if (istype(tool, /obj/item/airlock_electronics))
		if (state < ASSEMBLY_STATE_WIRED)
			USE_FEEDBACK_FAILURE("[src] needs to be wired before you can install [src].")
			return TRUE
		if (electronics)
			USE_FEEDBACK_FAILURE("[src] already has [electronics] installed.")
			return TRUE
		if (!user.canUnEquip(tool))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] starts installing [tool] into [src]."),
			SPAN_NOTICE("You start installing [tool] into [src].")
		)
		if (!user.do_skilled(4 SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return TRUE
		if (state < ASSEMBLY_STATE_WIRED)
			USE_FEEDBACK_FAILURE("[src] needs to be wired before you can install [src].")
			return TRUE
		if (electronics)
			USE_FEEDBACK_FAILURE("[src] already has [electronics] installed.")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		state = ASSEMBLY_STATE_CIRCUIT
		electronics = tool
		update_state()
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] installs [tool] into [src]."),
			SPAN_NOTICE("You install [tool] into [src].")
		)
		return TRUE

	// Cable Coil - Add wiring
	if (isCoil(tool))
		if (state != ASSEMBLY_STATE_FRAME)
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
			SPAN_NOTICE("[user] starts wiring [src] with [tool]."),
			SPAN_NOTICE("You start wiring [src] with [tool].")
		)
		if (!user.do_skilled(4 SECONDS, SKILL_ELECTRICAL, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return TRUE
		if (state != ASSEMBLY_STATE_FRAME)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		if (!anchored)
			USE_FEEDBACK_FAILURE("[src] needs to be anchored before you can wire it.")
			return TRUE
		if (!cable.use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 1, "to wire [src].")
			return TRUE
		state = ASSEMBLY_STATE_WIRED
		update_state()
		user.visible_message(
			SPAN_NOTICE("[user] wires [src] with [tool]."),
			SPAN_NOTICE("You wire [src] with [tool].")
		)
		return TRUE

	// Material Stack - Add glass/plating
	if (istype(tool, /obj/item/stack/material))
		if (glass)
			USE_FEEDBACK_FAILURE("[src] already has [istext(glass) ? "[glass] plating" : "glass panel"] installed.")
			return TRUE
		var/obj/item/stack/material/stack = tool
		var/material_name = stack.get_material_name()
		// Glass Panel
		if (material_name == MATERIAL_GLASS)
			if (!stack.reinf_material)
				USE_FEEDBACK_FAILURE("[src] needs reinforced glass to make a glass panel.")
				return TRUE
			if (!stack.can_use(1))
				USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 1, "to make a glass panel.")
				return TRUE
			playsound(src, 'sound/items/Crowbar.ogg', 50, TRUE)
			user.visible_message(
				SPAN_NOTICE("[user] starts installing a glass panel into [src]."),
				SPAN_NOTICE("You start installing a glass panel into [src].")
			)
			if (!user.do_skilled(4 SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
				return TRUE
			if (glass)
				USE_FEEDBACK_FAILURE("[src] already has [istext(glass) ? "[glass] plating" : "glass panel"] installed.")
				return TRUE
			if (!stack.reinf_material)
				USE_FEEDBACK_FAILURE("[src] needs reinforced glass to make a glass panel.")
				return TRUE
			if (!stack.use(1))
				USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 1, "to make a glass panel.")
				return TRUE
			glass = TRUE
			update_state()
			playsound(src, 'sound/items/Crowbar.ogg', 50, TRUE)
			user.visible_message(
				SPAN_NOTICE("[user] starts installing a glass panel into [src]."),
				SPAN_NOTICE("You start installing a glass panel into [src].")
			)
			return TRUE
		// Plating
		if (material_name in reinforcement_materials)
			if (!stack.can_use(2))
				USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 2, "to reinforce [src].")
				return TRUE
			playsound(src, 'sound/items/Crowbar.ogg', 50, TRUE)
			user.visible_message(
				SPAN_NOTICE("[user] starts installing [material_name] plating into [src]."),
				SPAN_NOTICE("You start installing [material_name] plating into [src].")
			)
			if (!user.do_skilled(4 SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
				return TRUE
			if (glass)
				USE_FEEDBACK_FAILURE("[src] already has [istext(glass) ? "[glass] plating" : "glass panel"] installed.")
				return TRUE
			if (!stack.use(2))
				USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 2, "to reinforce [src].")
				return TRUE
			glass = material_name
			update_state()
			playsound(src, 'sound/items/Crowbar.ogg', 50, TRUE)
			user.visible_message(
				SPAN_NOTICE("[user] installs [material_name] plating into [src]."),
				SPAN_NOTICE("You install [material_name] plating into [src].")
			)
			return TRUE
		USE_FEEDBACK_FAILURE("[src] can't be reinforced with [material_name].")
		return TRUE

	// Pen - Name door
	if (istype(tool, /obj/item/pen))
		var/input = input(user, "Enter the name for the door", "[src] - Name", created_name) as null|text
		input = sanitizeSafe(input, MAX_NAME_LEN)
		if (!input || input == created_name || !user.use_sanity_check(src, tool))
			return TRUE
		created_name = input
		update_state()
		user.visible_message(
			SPAN_NOTICE("[user] names [src] to '[created_name]' with [tool]."),
			SPAN_NOTICE("You name [src] to '[created_name]' with [tool].")
		)
		return TRUE

	return ..()


/obj/structure/door_assembly/proc/update_state()
	ClearOverlays()
	var/image/filling_overlay
	var/image/panel_overlay
	var/final_name = ""
	if(glass == 1)
		filling_overlay = image(glass_icon, "construction")
	else
		filling_overlay = image(fill_icon, "construction")
	switch (state)
		if(0)
			if (anchored)
				final_name = "Secured "
		if(1)
			final_name = "Wired "
			panel_overlay = image(panel_icon, "construction0")
		if(2)
			final_name = "Near Finished "
			panel_overlay = image(panel_icon, "construction1")
	final_name += "[glass == 1 ? "Window " : ""][istext(glass) ? "[glass] Airlock" : base_name] Assembly"
	SetName(final_name)
	AddOverlays(filling_overlay)
	AddOverlays(panel_overlay)
