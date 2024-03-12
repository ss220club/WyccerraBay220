#define ASSEMBLY_NONE 0
#define ASSEMBLY_WRENCHED 1
#define ASSEMBLY_WELDED 2
#define ASSEMBLY_WIRED 3 // you can now attach/dettach upgrades
#define ASSEMBLY_SCREWED 4 // you cannot attach upgrades

/obj/item/camera_assembly
	name = "camera assembly"
	desc = "A pre-fabricated security camera kit, ready to be assembled and mounted to a surface."
	icon = 'icons/obj/structures/cameras.dmi'
	icon_state = "cameracase"
	w_class = ITEM_SIZE_SMALL
	anchored = FALSE

	matter = list(MATERIAL_ALUMINIUM = 700, MATERIAL_GLASS = 300)

	//	Motion, EMP-Proof, X-Ray
	var/list/obj/item/possible_upgrades = list(/obj/item/device/assembly/prox_sensor, /obj/item/stack/material/osmium, /obj/item/stock_parts/scanning_module)
	var/list/upgrades = list()
	var/camera_name
	var/camera_network
	var/state = ASSEMBLY_NONE

/obj/item/camera_assembly/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(state != ASSEMBLY_WIRED || !length(upgrades))
		return
	var/obj/U = locate(/obj) in upgrades
	if(U)
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		to_chat(user, SPAN_NOTICE("You unattach an upgrade from the assembly."))
		U.dropInto(loc)
		upgrades -= U

/obj/item/camera_assembly/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(state == ASSEMBLY_WIRED)
		var/input = sanitize(input(user, "Which networks would you like to connect this camera to? Separate networks with a comma. No Spaces!\nFor example: Exodus,Security,Secret", "Set Network", camera_network ? camera_network : NETWORK_EXODUS))
		if(!input)
			to_chat(user, "No input found please hang up and try your call again.")
			return
		var/list/tempnetwork = splittext(input, ",")
		if(length(tempnetwork) < 1)
			to_chat(user, "No network found please hang up and try your call again.")
			return
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		var/area/camera_area = get_area(src)
		var/temptag = "[sanitize(camera_area.name)] ([rand(1, 999)])"
		input = sanitizeSafe(input(user, "How would you like to name the camera?", "Set Camera Name", camera_name ? camera_name : temptag), MAX_LNAME_LEN)
		state = ASSEMBLY_SCREWED
		var/obj/machinery/camera/C = new(loc)
		forceMove(C)
		C.assembly = src
		C.auto_turn()
		C.replace_networks(uniquelist(tempnetwork))
		C.c_tag = input
		for(var/i = 5; i >= 0; i -= 1)
			var/direct = input(user, "Direction?", "Assembling Camera", null) in list("LEAVE IT", "NORTH", "EAST", "SOUTH", "WEST" )
			if(direct != "LEAVE IT")
				C.dir = text2dir(direct)
			if(i != 0)
				var/confirm = alert(user, "Is this what you want? Chances Remaining: [i]", "Confirmation", "Yes", "No")
				if(confirm == "Yes")
					C.update_icon()
					break

/obj/item/camera_assembly/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	switch(state)
		if(ASSEMBLY_NONE)
			if(!isturf(loc))
				return
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			to_chat(user, "You wrench the assembly into place.")
			anchored = TRUE
			state = ASSEMBLY_WRENCHED
			update_icon()
			auto_turn()
		if(ASSEMBLY_WRENCHED)
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			to_chat(user, "You unattach the assembly from its place.")
			anchored = FALSE
			update_icon()
			state = ASSEMBLY_NONE

/obj/item/camera_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(state != ASSEMBLY_WIRED)
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	new/obj/item/stack/cable_coil(get_turf(src), 2)
	to_chat(user, "You cut the wires from the circuits.")
	state = ASSEMBLY_WELDED

/obj/item/camera_assembly/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	switch(state)
		if(ASSEMBLY_WRENCHED)
			if(!tool.tool_start_check(user, 1))
				return
			balloon_alert(user, "приваривание камеры")
			if(!tool.use_as_tool(src, user, 2 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
				return
			balloon_alert(user, "камера приварена")
			anchored = TRUE
			state = ASSEMBLY_WELDED
		if(ASSEMBLY_WELDED)
			if(!tool.tool_start_check(user, 1))
				return
			balloon_alert(user, "отваривание камеры")
			if(!tool.use_as_tool(src, user, 2 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
				return
			balloon_alert(user, "камера отварена")
			state = ASSEMBLY_WRENCHED
			anchored = TRUE

/obj/item/camera_assembly/attackby(obj/item/W as obj, mob/living/user as mob)
	switch(state)
		if(ASSEMBLY_WELDED)
			// State 2
			if(isCoil(W))
				var/obj/item/stack/cable_coil/C = W
				if(C.use(2))
					to_chat(user, SPAN_NOTICE("You add wires to the assembly."))
					state = ASSEMBLY_WIRED
				else
					to_chat(user, SPAN_WARNING("You need 2 coils of wire to wire the assembly."))
				return

	// Upgrades!
	if(is_type_in_list(W, possible_upgrades) && !is_type_in_list(W, upgrades) && user.unEquip(W, src)) // Is a possible upgrade and isn't in the camera already.
		to_chat(user, "You attach [W] into the assembly inner circuits.")
		upgrades += W
		return
	..()

/obj/item/camera_assembly/on_update_icon()
	if(anchored)
		icon_state = "camera1"
	else
		icon_state = "cameracase"

/obj/item/camera_assembly/attack_hand(mob/user as mob)
	if(!anchored)
		..()

#undef ASSEMBLY_NONE
#undef ASSEMBLY_WRENCHED
#undef ASSEMBLY_WELDED
#undef ASSEMBLY_WIRED
#undef ASSEMBLY_SCREWED
