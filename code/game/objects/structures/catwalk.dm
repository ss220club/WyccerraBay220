/obj/structure/catwalk
	name = "catwalk"
	desc = "Cats really don't like these things."
	icon = 'icons/obj/structures/catwalks.dmi'
	icon_state = "catwalk"
	density = FALSE
	anchored = TRUE
	layer = CATWALK_LAYER
	footstep_type = /singleton/footsteps/catwalk
	obj_flags = OBJ_FLAG_NOFALL
	var/hatch_open = FALSE
	var/obj/item/stack/tile/mono/plated_tile

/obj/structure/catwalk/Initialize()
	. = ..()
	DELETE_IF_DUPLICATE_OF(/obj/structure/catwalk)
	update_connections(1)
	update_icon()


/obj/structure/catwalk/Destroy()
	redraw_nearby_catwalks()
	return ..()

/obj/structure/catwalk/proc/redraw_nearby_catwalks()
	for(var/direction in GLOB.alldirs)
		var/obj/structure/catwalk/L = locate() in get_step(src, direction)
		if(L)
			L.update_connections()
			L.update_icon() //so siding get updated properly


/obj/structure/catwalk/on_update_icon()
	update_connections()
	ClearOverlays()
	icon_state = ""
	var/image/I
	if(!hatch_open)
		for(var/i = 1 to 4)
			I = image('icons/obj/structures/catwalks.dmi', "catwalk[connections[i]]", dir = SHIFTL(1, i - 1))
			AddOverlays(I)
	if(plated_tile)
		I = image('icons/obj/structures/catwalks.dmi', "plated")
		I.color = plated_tile.color
		AddOverlays(I)

/obj/structure/catwalk/ex_act(severity)
	switch(severity)
		if(EX_ACT_DEVASTATING)
			new /obj/item/stack/material/rods(src.loc)
			qdel(src)
		if(EX_ACT_HEAVY)
			new /obj/item/stack/material/rods(src.loc)
			qdel(src)

/obj/structure/catwalk/attack_hand(mob/user)
	if(user.pulling)
		do_pull_click(user, src)
	..()

/obj/structure/catwalk/attack_robot(mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/catwalk/proc/deconstruct(mob/user)
	new /obj/item/stack/material/rods(src.loc)
	new /obj/item/stack/material/rods(src.loc)
	//Lattice would delete itself, but let's save ourselves a new obj
	if(istype(src.loc, /turf/space) || istype(src.loc, /turf/simulated/open))
		new /obj/structure/lattice/(src.loc)
	if(plated_tile)
		new plated_tile.build_type(src.loc)
	qdel(src)

/obj/structure/catwalk/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!plated_tile)
		USE_FEEDBACK_FAILURE("[src] is not plated and has no hatch to open.")
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	hatch_open = !hatch_open
	update_icon()
	user.visible_message(
		SPAN_NOTICE("[user] pries [src]'s maintenance hatch open with [tool]."),
		SPAN_NOTICE("You pry [src]'s maintenance hatch open with [tool].")
	)

/obj/structure/catwalk/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, amount = 1, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	deconstruct(user)

/obj/structure/catwalk/use_tool(obj/item/tool, mob/user, list/click_params)
	// Floor Tile - Plate catwalk
	if (istype(tool, /obj/item/stack/tile))
		if (plated_tile)
			USE_FEEDBACK_FAILURE("[src] is already plated.")
			return TRUE
		var/obj/item/stack/tile/stack = tool
		if (!stack.can_use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 1, "to plate [src].")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] starts plating [src] with [tool]."),
			SPAN_NOTICE("You start plating [src] with [tool].")
		)
		if (!user.do_skilled(1 SECOND, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return TRUE
		if (!stack.use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 1, "to plate [src].")
			return TRUE
		var/list/singletons = GET_SINGLETON_SUBTYPE_MAP(/singleton/flooring)
		for (var/flooring_type in singletons)
			var/singleton/flooring/F = singletons[flooring_type]
			if (!F.build_type)
				continue
			if (ispath(stack.type, F.build_type))
				plated_tile = F
				break
		update_icon()
		SetName("plated catwalk")
		user.visible_message(
			SPAN_NOTICE("[user] plates [src] with [tool]."),
			SPAN_NOTICE("You plate [src] with [tool].")
		)
		return TRUE

	return ..()


/obj/structure/catwalk/refresh_neighbors()
	return

/obj/catwalk_plated
	name = "plated catwalk spawner"
	icon = 'icons/obj/structures/catwalks.dmi'
	icon_state = "catwalk_plated"
	density = TRUE
	anchored = TRUE
	var/activated = FALSE
	layer = CATWALK_LAYER
	var/plating_type = /singleton/flooring/tiling/mono

/obj/catwalk_plated/Initialize(mapload)
	. = ..()
	var/auto_activate = mapload || (GAME_STATE < RUNLEVEL_GAME)
	if(auto_activate)
		activate()
		return INITIALIZE_HINT_QDEL

/obj/catwalk_plated/CanPass()
	return 0

/obj/catwalk_plated/attack_hand()
	attack_generic()

/obj/catwalk_plated/attack_ghost()
	attack_generic()

/obj/catwalk_plated/attack_generic()
	activate()

/obj/catwalk_plated/proc/activate()
	if(activated) return

	if(locate(/obj/structure/catwalk) in loc)
		warning("Frame Spawner: A catwalk already exists at [loc.x]-[loc.y]-[loc.z]")
	else
		var/obj/structure/catwalk/C = new /obj/structure/catwalk(loc)
		C.plated_tile += new plating_type
		C.name = "plated catwalk"
		C.update_icon()
	activated = 1

	for(var/obj/wallframe_spawn/other in orange(src, 1))
		if(!other.activated)
			other.activate()

/obj/catwalk_plated/dark
	icon_state = "catwalk_plateddark"
	plating_type = /singleton/flooring/tiling/mono/dark

/obj/catwalk_plated/white
	icon_state = "catwalk_platedwhite"
	plating_type = /singleton/flooring/tiling/mono/white
