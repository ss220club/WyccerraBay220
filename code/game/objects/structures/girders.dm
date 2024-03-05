/obj/structure/girder
	icon_state = "girder"
	anchored = TRUE
	density = TRUE
	layer = BELOW_OBJ_LAYER
	w_class = ITEM_SIZE_NO_CONTAINER
	health_max = 100
	var/const/GIRDER_STATE_NORMAL = 0
	var/const/GIRDER_STATE_REINFORCEMENT_UNSECURED = 1
	var/const/GIRDER_STATE_REINFORCED = 2
	var/state = GIRDER_STATE_NORMAL
	var/cover = 50 //how much cover the girder provides against projectiles.
	var/material/reinf_material
	var/reinforcing = 0

/obj/structure/girder/Initialize()
	set_extension(src, /datum/extension/penetration/simple, 100)
	. = ..()

/obj/structure/girder/displaced
	icon_state = "displaced"
	anchored = FALSE
	health_max = 50
	cover = 25

/obj/structure/girder/bullet_act(obj/item/projectile/Proj)
	//Girders only provide partial cover. There's a chance that the projectiles will just pass through. (unless you are trying to shoot the girder)
	if(Proj.original != src && !prob(cover))
		return PROJECTILE_CONTINUE //pass through
	. = ..()

/obj/structure/girder/on_death()
	dismantle()

/obj/structure/girder/CanFluidPass(coming_from)
	return TRUE

/obj/structure/girder/proc/reset_girder()
	anchored = TRUE
	cover = initial(cover)
	revive_health()
	state = GIRDER_STATE_NORMAL
	icon_state = initial(icon_state)
	reinforcing = 0
	if(reinf_material)
		reinforce_girder()


/obj/structure/girder/can_anchor(obj/item/tool, mob/user, silent)
	if (reinf_material || state != GIRDER_STATE_NORMAL)
		if (!silent)
			USE_FEEDBACK_FAILURE("[src]'s reinforcements must be removed before it can be moved.")
		return FALSE

	return ..()

/obj/structure/girder/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!can_anchor(tool, user))
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts dislodging [src] with [tool]."),
		SPAN_NOTICE("You start dislodging [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT, extra_checks = CALLBACK(src, PROC_REF(can_anchor), tool, user)))
		return
	icon_state = "displaced"
	anchored = FALSE
	set_max_health(50)
	cover = 25
	user.visible_message(
		SPAN_NOTICE("[user] dislodges [src] with [tool]."),
		SPAN_NOTICE("You dislodge [src] with [tool].")
	)

/obj/structure/girder/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	// Screwdriver
	// - Unsecure support struts
	// - Allow reinforcement
	switch(state)
		if(GIRDER_STATE_NORMAL)
			if(!anchored)
				USE_FEEDBACK_FAILURE("[src] needs to be anchored before you can add reinforcements.")
				return
			if(reinf_material)
				USE_FEEDBACK_FAILURE("[src] already has [reinf_material.adjective_name] reinforcement.")
				return
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			reinforcing = !reinforcing
			user.visible_message(
				SPAN_NOTICE("[user] adjusts [src] with [tool]. It can now be [reinforcing ? "reinforced" : "constructed"]."),
				SPAN_NOTICE("You adjust [src] with [tool]. It can now be [reinforcing ? "reinforced" : "constructed"].")
			)
		if(GIRDER_STATE_REINFORCEMENT_UNSECURED)
			user.visible_message(
				SPAN_NOTICE("[user] starts securing [src]'s support struts with [tool]."),
				SPAN_NOTICE("You starts securing [src]'s support struts with [tool].")
			)
			if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || state != GIRDER_STATE_REINFORCEMENT_UNSECURED)
				return
			state = GIRDER_STATE_REINFORCED
			user.visible_message(
				SPAN_NOTICE("[user] secures [src]'s support struts with [tool]."),
				SPAN_NOTICE("You secure [src]'s support struts with [tool].")
			)
		if(GIRDER_STATE_REINFORCED)
			user.visible_message(
				SPAN_NOTICE("[user] starts unsecuring [src]'s support struts with [tool]."),
				SPAN_NOTICE("You starts unsecuring [src]'s support struts with [tool].")
			)
			if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || state != GIRDER_STATE_REINFORCED)
				return
			state = GIRDER_STATE_REINFORCEMENT_UNSECURED
			user.visible_message(
				SPAN_NOTICE("[user] unsecures [src]'s support struts with [tool]."),
				SPAN_NOTICE("You unsecure [src]'s support struts with [tool].")
			)

/obj/structure/girder/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	// Wrench - Dismantle girder
	if(state != GIRDER_STATE_NORMAL)
		USE_FEEDBACK_FAILURE("[src]'s reinforcements must be removed before it can be dismantled.")
		return
	if(anchored)
		user.visible_message(
			SPAN_NOTICE("[user] starts dismantling [src] with [tool]."),
			SPAN_NOTICE("You start dismantling [src] with [tool].")
		)
		if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || state != GIRDER_STATE_NORMAL || !anchored)
			return
		user.visible_message(
			SPAN_NOTICE("[user] dismantles [src] with [tool]."),
			SPAN_NOTICE("You dismantle [src] with [tool].")
		)
		dismantle()
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts securing [src] with [tool]."),
		SPAN_NOTICE("You start securing [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || state != GIRDER_STATE_NORMAL || anchored)
		return
	user.visible_message(
		SPAN_NOTICE("[user] secures [src] with [tool]."),
		SPAN_NOTICE("You secure [src] with [tool].")
	)
	reset_girder()

/obj/structure/girder/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	switch (state)
		if (GIRDER_STATE_NORMAL)
			USE_FEEDBACK_FAILURE("[src] has no reinforcements to remove.")
		if (GIRDER_STATE_REINFORCEMENT_UNSECURED)
			playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
			user.visible_message(
				SPAN_NOTICE("[user] starts removing [src]'s support struts with [tool]."),
				SPAN_NOTICE("You start removing [src]'s support struts with [tool].")
			)
			if (!user.do_skilled((tool.toolspeed * 4) SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
				return
			if (state != GIRDER_STATE_REINFORCEMENT_UNSECURED)
				USE_FEEDBACK_FAILURE("[src]'s state has changed.")
				return
			playsound(src, 'sound/items/Wirecutter.ogg', 50, TRUE)
			if (reinf_material)
				reinf_material.place_dismantled_product(get_turf(src))
				reinf_material = null
			reset_girder()
			user.visible_message(
				SPAN_NOTICE("[user] removes [src]'s support struts with [tool]."),
				SPAN_NOTICE("You remove [src]'s support struts with [tool].")
			)

/obj/structure/girder/use_tool(obj/item/tool, mob/user, list/click_params)
	// Diamond Drill, Plasmacutter, Psiblade (Paramount) - Slice girder
	if (istype(tool, /obj/item/pickaxe/diamonddrill) || istype(tool, /obj/item/gun/energy/plasmacutter) || istype(tool, /obj/item/psychic_power/psiblade/master/grand/paramount))
		var/obj/item/gun/energy/plasmacutter/cutter = tool
		if (istype(cutter) && !cutter.slice(user))
			return TRUE
		playsound(loc, 'sound/items/Welder.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] starts cutting [src] with [tool]."),
			SPAN_NOTICE("You start cutting [src] with [tool].")
		)
		if (!user.do_skilled((reinf_material ? 4 : 2) SECONDS, SKILL_CONSTRUCTION, src, do_flags = DO_REPAIR_CONSTRUCT) || !user.use_sanity_check(src, tool))
			return TRUE
		playsound(loc, 'sound/items/Welder.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] cuts apart [src] with [tool]."),
			SPAN_NOTICE("You cut apart [src] with [tool].")
		)
		if (reinf_material)
			reinf_material.place_dismantled_product(get_turf(src))
		dismantle()
		return TRUE

	// Material - Construct wall or reinforce
	if (istype(tool, /obj/item/stack/material))
		if (reinforcing && !reinf_material)
			reinforce_with_material(tool, user)
			return TRUE
		construct_wall(tool, user)
		return TRUE

	return ..()


/obj/structure/girder/proc/construct_wall(obj/item/stack/material/S, mob/user)
	if(S.get_amount() < 2)
		to_chat(user, SPAN_NOTICE("There isn't enough material here to construct a wall."))
		return 0

	var/material/M = SSmaterials.get_material_by_name(S.default_type)
	if(!istype(M))
		return 0

	var/wall_fake
	add_hiddenprint(usr)

	if(M.integrity < 50)
		to_chat(user, SPAN_NOTICE("This material is too soft for use in wall construction."))
		return 0

	to_chat(user, SPAN_NOTICE("You begin adding the plating..."))

	if(!do_after(user,4 SECONDS, src, DO_REPAIR_CONSTRUCT) || !S.use(2))
		return 1 //once we've gotten this far don't call parent attackby()

	if(anchored)
		to_chat(user, SPAN_NOTICE("You added the plating!"))
	else
		to_chat(user, SPAN_NOTICE("You create a false wall! Push on it to open or close the passage."))
		wall_fake = 1

	var/turf/Tsrc = get_turf(src)
	Tsrc.ChangeTurf(/turf/simulated/wall)
	var/turf/simulated/wall/T = get_turf(src)
	T.set_material(M, reinf_material)
	if(wall_fake)
		T.can_open = 1
	T.add_hiddenprint(usr)
	qdel(src)
	return 1

/obj/structure/girder/proc/reinforce_with_material(obj/item/stack/material/S, mob/user) //if the verb is removed this can be renamed.
	if(reinf_material)
		to_chat(user, SPAN_NOTICE("[src] is already reinforced."))
		return 0

	if(S.get_amount() < 2)
		to_chat(user, SPAN_NOTICE("There isn't enough material here to reinforce the girder."))
		return 0

	var/material/M = S.material
	if(!istype(M) || M.integrity < 50)
		to_chat(user, "You cannot reinforce [src] with that; it is too soft.")
		return 0

	to_chat(user, SPAN_NOTICE("Now reinforcing..."))
	if (!do_after(user, 4 SECONDS, src, DO_REPAIR_CONSTRUCT) || !S.use(2))
		return 1 //don't call parent attackby() past this point
	to_chat(user, SPAN_NOTICE("You added reinforcement!"))

	reinf_material = M
	reinforce_girder()
	return 1

/obj/structure/girder/proc/reinforce_girder()
	cover = 75
	set_max_health(500)
	state = GIRDER_STATE_REINFORCED
	icon_state = "reinforced"
	reinforcing = 0

/obj/structure/girder/proc/dismantle()
	new /obj/item/stack/material/steel(get_turf(src))
	qdel(src)

/obj/structure/girder/cult
	icon= 'icons/obj/cult.dmi'
	icon_state= "cultgirder"
	health_max = 250
	cover = 70

/obj/structure/girder/cult/dismantle()
	qdel(src)
