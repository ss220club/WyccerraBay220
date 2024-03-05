/obj/structure/plasticflaps //HOW DO YOU CALL THOSE THINGS ANYWAY
	name = "\improper plastic flaps"
	desc = "Completely impassable - or are they?"
	icon = 'icons/obj/plastic_flaps.dmi' //Change this.
	icon_state = "plasticflaps"
	density = FALSE
	anchored = TRUE
	layer = ABOVE_HUMAN_LAYER
	explosion_resistance = 5
	obj_flags = OBJ_FLAG_ANCHORABLE

	atmos_canpass = CANPASS_PROC

	var/list/mobs_can_pass = list(
		/mob/living/bot,
		/mob/living/carbon/slime,
		/mob/living/simple_animal/passive/mouse,
		/mob/living/silicon/robot/drone
		)
	var/airtight = FALSE

/obj/structure/plasticflaps/CanPass(atom/A, turf/T)
	if(istype(A) && A.checkpass(PASS_FLAG_GLASS))
		return prob(60)

	var/obj/structure/bed/B = A
	if (istype(A, /obj/structure/bed) && B.buckled_mob)//if it's a bed/chair and someone is buckled, it will not pass
		return 0

	var/mob/living/M = A
	if(istype(M))
		if(M.lying)
			return ..()
		for(var/mob_type in mobs_can_pass)
			if(istype(A, mob_type))
				return ..()
		return issmall(M)

	return ..()

/obj/structure/plasticflaps/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(anchored)
		USE_FEEDBACK_FAILURE("[src] has to be unanchored before you can deconstruct it.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts deconstructing [src] with [tool]."),
		SPAN_NOTICE("You start deconstructing [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 3 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || anchored)
		return
	var/obj/item/stack/material/plastic/stack = new(loc, 30)
	transfer_fingerprints_to(stack)
	user.visible_message(
		SPAN_NOTICE("[user] deconstructs [src] with [tool]."),
		SPAN_NOTICE("You deconstruct [src] with [tool].")
	)
	qdel(src)

/obj/structure/plasticflaps/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	// Screwdriver - Toggle airflow
	if (anchored)
		USE_FEEDBACK_FAILURE("[src] has to be unanchored before you can adjust the airflow.")
		return
	if (airtight)
		clear_airtight()
	else
		become_airtight()
	user.visible_message(
		SPAN_NOTICE("[user] adjusts [src] with [tool]."),
		SPAN_NOTICE("You adjust [src] with [tool], [airtight ? "preventing" : "allowing"] air flow.")
	)


/obj/structure/plasticflaps/can_anchor(obj/item/tool, mob/user, silent)
	. = ..()
	if (!.)
		return
	if (airtight)
		if (!silent)
			USE_FEEDBACK_FAILURE("You have to readjust the airflow before unwrenching [src].")
		return FALSE


/obj/structure/plasticflaps/ex_act(severity)
	switch(severity)
		if (EX_ACT_DEVASTATING)
			qdel(src)
		if (EX_ACT_HEAVY)
			if (prob(50))
				qdel(src)
		if (EX_ACT_LIGHT)
			if (prob(5))
				qdel(src)

/obj/structure/plasticflaps/Destroy()
	if (airtight)
		clear_airtight()
	. = ..()

/obj/structure/plasticflaps/c_airblock()
	if (airtight == TRUE)
		return AIR_BLOCKED
	return FALSE

/obj/structure/plasticflaps/proc/become_airtight()
	airtight = TRUE
	var/turf/simulated/floor/T = get_turf(loc)
	if (istype(T))
		update_nearby_tiles()

/obj/structure/plasticflaps/proc/clear_airtight()
	airtight = FALSE
	var/turf/simulated/floor/T = get_turf(loc)
	if (istype(T))
		update_nearby_tiles()

/obj/structure/plasticflaps/airtight // airtight defaults to on
	airtight = TRUE

/obj/structure/plasticflaps/airtight/Initialize()
	. = ..()
	update_nearby_tiles()
