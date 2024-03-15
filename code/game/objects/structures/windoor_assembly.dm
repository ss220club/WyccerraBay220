/* Windoor (window door) assembly -Nodrak
 * Step 1: Create a windoor out of rglass
 * Step 2: Add r-glass to the assembly to make a secure windoor (Optional)
 * Step 3: Rotate or Flip the assembly to face and open the way you want
 * Step 4: Wrench the assembly in place
 * Step 5: Add cables to the assembly
 * Step 6: Set access for the door.
 * Step 7: Crowbar the door to complete
 */


/obj/structure/windoor_assembly
	name = "windoor assembly"
	icon = 'icons/obj/doors/windoor.dmi'
	icon_state = "l_windoor_assembly01"
	anchored = FALSE
	density = FALSE
	dir = NORTH
	w_class = ITEM_SIZE_NORMAL
	obj_flags = OBJ_FLAG_ANCHORABLE

	var/obj/item/airlock_electronics/electronics = null

	//Vars to help with the icon's name
	var/facing = "l"	//Does the windoor open to the left or right?
	var/secure = ""		//Whether or not this creates a secure windoor

	var/const/WINDOOR_STATE_FRAME = "01"
	var/const/WINDOOR_STATE_WIRED = "02"
	/// String (One of `WINDOOR_STATE_*`). How far the door assembly has progressed in terms of sprites
	var/state = WINDOOR_STATE_FRAME

/obj/structure/windoor_assembly/New(Loc, start_dir=NORTH, constructed=0)
	..()
	if(constructed)
		state = WINDOOR_STATE_FRAME
		anchored = FALSE
	switch(start_dir)
		if(NORTH, SOUTH, EAST, WEST)
			set_dir(start_dir)
		else //If the user is facing northeast. northwest, southeast, southwest or north, default to north
			set_dir(NORTH)

	update_nearby_tiles(need_rebuild=1)

/obj/structure/windoor_assembly/Destroy()
	set_density(0)
	update_nearby_tiles()
	..()

/obj/structure/windoor_assembly/on_update_icon()
	icon_state = "[facing]_[secure]windoor_assembly[state]"

/obj/structure/windoor_assembly/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASS_FLAG_GLASS))
		return 1
	if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
		if(air_group) return 0
		return !density
	else
		return 1

/obj/structure/windoor_assembly/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASS_FLAG_GLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1


/obj/structure/windoor_assembly/can_anchor(obj/item/tool, mob/user, silent)
	. = ..()
	if (!.)
		return
	if (state != WINDOOR_STATE_FRAME)
		if (!silent)
			USE_FEEDBACK_FAILURE("[src]'s wiring must be removed before you can unanchor it.")
		return FALSE

/obj/structure/windoor_assembly/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!electronics)
		USE_FEEDBACK_FAILURE("[src] needs a circuit board before you can complete it.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts prying [src] into its frame with [tool]."),
		SPAN_NOTICE("You start prying [src] into its frame with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || !electronics)
		return
	var/obj/machinery/door/window/windoor
	if(secure)
		windoor = new /obj/machinery/door/window/brigdoor(loc, src)
	else
		windoor = new (loc, src)
	if(facing == "l")
		windoor.base_state = "left"
	else
		windoor.base_state = "right"
	transfer_fingerprints_to(windoor)
	user.visible_message(
		SPAN_NOTICE("[user] finishes [windoor] with [tool]."),
		SPAN_NOTICE("You finish [windoor] with [tool].")
	)
	qdel(src)

/obj/structure/windoor_assembly/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!electronics)
		balloon_alert(user, "нет платы!")
		return
	balloon_alert(user, "снятие платы")
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || !electronics)
		return
	electronics.dropInto(loc)
	electronics.add_fingerprint(user, tool = tool)
	electronics = null
	update_icon()
	balloon_alert_to_viewers("плата снята")

/obj/structure/windoor_assembly/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(state != WINDOOR_STATE_WIRED)
		USE_FEEDBACK_FAILURE("[src] has no wiring to remove.")
		return
	if(electronics)
		USE_FEEDBACK_FAILURE("[src]'s electronics need to be removed before you can cut the wiring.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts cutting [src]'s wiring with [tool]."),
		SPAN_NOTICE("You start cutting [src]'s wiring with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_ELECTRICAL, do_flags = DO_REPAIR_CONSTRUCT) || state != WINDOOR_STATE_WIRED || electronics)
		return
	var/obj/item/stack/cable_coil/cable = new (loc, 1)
	cable.add_fingerprint(user, tool = tool)
	state = WINDOOR_STATE_FRAME
	update_icon()
	user.visible_message(
		SPAN_NOTICE("[user] cuts [src]'s wiring with [tool]."),
		SPAN_NOTICE("You cut [src]'s wiring with [tool].")
	)

/obj/structure/windoor_assembly/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(state != WINDOOR_STATE_FRAME)
		USE_FEEDBACK_FAILURE("[src]'s wiring must be removed before you can dismantle it.")
		return
	if(anchored)
		USE_FEEDBACK_FAILURE("[src] needs to be unanchored before you can dismantle it.")
		return
	if(!tool.tool_start_check(user, 1))
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts dismantling [src] with [tool]."),
		SPAN_NOTICE("You start dismantling [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || state != WINDOOR_STATE_FRAME || anchored)
		return
	var/obj/item/stack/material/glass/reinforced/glass = new(loc, 5)
	transfer_fingerprints_to(glass)
	if(secure)
		var/obj/item/stack/material/rods/rods = new(loc, 4)
		transfer_fingerprints_to(rods)
	user.visible_message(
		SPAN_NOTICE("[user] dismantles [src] with [tool]."),
		SPAN_NOTICE("You dismantle [src] with [tool].")
	)
	qdel(src)

/obj/structure/windoor_assembly/use_tool(obj/item/tool, mob/user, list/click_params)
	// Airlock electronics - Install electronics
	if (istype(tool, /obj/item/airlock_electronics))
		if (state != WINDOOR_STATE_WIRED)
			USE_FEEDBACK_FAILURE("[src] needs to be wired before you can install [tool].")
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
		if (state != WINDOOR_STATE_WIRED)
			USE_FEEDBACK_FAILURE("[src] needs to be wired before you can install [tool].")
			return TRUE
		if (electronics)
			USE_FEEDBACK_FAILURE("[src] already has [electronics] installed.")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		electronics = tool
		update_icon()
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] installs [tool] into [src]."),
			SPAN_NOTICE("You install [tool] into [src].")
		)
		return TRUE

	// Cable Coil - Wire assembly
	if (istype(tool, /obj/item/stack/cable_coil))
		if (state != WINDOOR_STATE_FRAME)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		if (!anchored)
			USE_FEEDBACK_FAILURE("[src] must be anchored before you can wire it.")
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
		if (state != WINDOOR_STATE_FRAME)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		if (!anchored)
			USE_FEEDBACK_FAILURE("[src] must be anchored before you can wire it.")
			return TRUE
		if (!cable.use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 1, "to wire [src].")
			return TRUE
		state = WINDOOR_STATE_WIRED
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] wires [src] with [tool]."),
			SPAN_NOTICE("You wires [src] with [tool].")
		)
		return TRUE

	// Rods - Make assembly secure
	if (istype(tool, /obj/item/stack/material/rods))
		if (state != WINDOOR_STATE_FRAME)
			USE_FEEDBACK_FAILURE("[src]'s wiring must be removed before you can reinforce it.")
			return TRUE
		if (secure)
			USE_FEEDBACK_FAILURE("[src] already has reinforcements installed.")
			return TRUE
		var/obj/item/stack/material/rods/rods = tool
		if (!rods.can_use(4))
			USE_FEEDBACK_STACK_NOT_ENOUGH(rods, 4, "to reinforce [src].")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] starts reinforcing [src] with some [tool.name]."),
			SPAN_NOTICE("You start reinforcing [src] with some [tool.name].")
		)
		if (!user.do_skilled(4 SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return TRUE
		if (state != WINDOOR_STATE_FRAME)
			USE_FEEDBACK_FAILURE("[src]'s wiring must be removed before you can reinforce it.")
			return TRUE
		if (secure)
			USE_FEEDBACK_FAILURE("[src] already has reinforcements installed.")
			return TRUE
		if (!rods.use(4))
			USE_FEEDBACK_STACK_NOT_ENOUGH(rods, 4, "to reinforce [src].")
			return TRUE
		secure = "secure_"
		SetName("secure [initial(name)]")
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] reinforces [src] with some [tool.name]."),
			SPAN_NOTICE("You reinforce [src] with some [tool.name].")
		)
		return TRUE

	return ..()


//Rotates the windoor assembly clockwise
/obj/structure/windoor_assembly/verb/revrotate()
	set name = "Rotate Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if (src.anchored)
		to_chat(usr, "It is fastened to the floor; therefore, you can't rotate it!")
		return 0
	if(src.state != WINDOOR_STATE_FRAME)
		update_nearby_tiles(need_rebuild=1) //Compel updates before

	src.set_dir(turn(src.dir, 270))

	if(src.state != WINDOOR_STATE_FRAME)
		update_nearby_tiles(need_rebuild=1)

	update_icon()
	return

//Flips the windoor assembly, determines whather the door opens to the left or the right
/obj/structure/windoor_assembly/verb/flip()
	set name = "Flip Windoor Assembly"
	set category = "Object"
	set src in oview(1)

	if(src.facing == "l")
		to_chat(usr, "The windoor will now slide to the right.")
		src.facing = "r"
	else
		src.facing = "l"
		to_chat(usr, "The windoor will now slide to the left.")

	update_icon()
	return
