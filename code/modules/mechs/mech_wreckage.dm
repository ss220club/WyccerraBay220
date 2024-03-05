/obj/structure/mech_wreckage
	name = "wreckage"
	desc = "It might have some salvagable parts."
	density = TRUE
	opacity = 1
	anchored = TRUE
	icon_state = "wreck"
	icon = 'icons/mecha/mech_part_items.dmi'
	health_max = 100
	health_min_damage = 20
	var/prepared

/obj/structure/mech_wreckage/New(newloc, mob/living/exosuit/exosuit, gibbed)
	if(exosuit)
		name = "wreckage of [exosuit.name]"
		if(!gibbed)
			for(var/obj/item/thing in list(exosuit.arms, exosuit.legs, exosuit.head, exosuit.body))
				if(thing && prob(40))
					thing.forceMove(src)
			for(var/hardpoint in exosuit.hardpoints)
				if(exosuit.hardpoints[hardpoint])
					if(prob(40))
						var/obj/item/thing = exosuit.hardpoints[hardpoint]
						if(exosuit.remove_system(hardpoint))
							thing.forceMove(src)
					else
						//This has been destroyed, some modules may need to perform bespoke logic
						var/obj/item/mech_equipment/E = exosuit.hardpoints[hardpoint]
						if(istype(E))
							E.wreck()

	..()

/obj/structure/mech_wreckage/powerloader/New(newloc)
	..(newloc, new /mob/living/exosuit/premade/powerloader(newloc), FALSE)

/obj/structure/mech_wreckage/attack_hand(mob/user)
	if(length(contents))
		var/obj/item/thing = pick(contents)
		if(istype(thing))
			thing.forceMove(get_turf(user))
			user.put_in_hands(thing)
			to_chat(user, "You retrieve [thing] from [src].")
			return
	return ..()


/obj/structure/mech_wreckage/on_death()
	. = ..()
	visible_message(SPAN_WARNING("[src] breaks apart!"))
	new /obj/item/stack/material/steel(loc, rand(1, 3))
	qdel_self()

/obj/structure/mech_wreckage/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if (!prepared)
		USE_FEEDBACK_FAILURE("[src] is too solid to dismantle. Try cutting through it first.")
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	new /obj/item/stack/material/steel(loc, rand(5, 10))
	user.visible_message(
		SPAN_NOTICE("[user] finishes dismantling [src] with [tool]."),
		SPAN_NOTICE("You finish dismantling [src] with [tool].")
	)
	qdel(src)

/obj/structure/mech_wreckage/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if (prepared)
		USE_FEEDBACK_FAILURE("[src] has already been weakened.")
		return
	var/obj/item/weldingtool/welder = tool
	if (!welder.remove_fuel(1, user))
		return
	prepared = TRUE
	user.visible_message(
		SPAN_NOTICE("[user] partially cuts through [src] with [tool]."),
		SPAN_NOTICE("You partially cut through [src] with [tool].")
	)

/obj/structure/mech_wreckage/use_tool(obj/item/tool, mob/user, list/click_params)
	// Welding Tool, Plasma Cutter - Cut through wreckage
	if(istype(tool, /obj/item/gun/energy/plasmacutter))
		if(prepared)
			USE_FEEDBACK_FAILURE("[src] has already been weakened.")
			return TRUE
		if(istype(tool, /obj/item/gun/energy/plasmacutter))
			var/obj/item/gun/energy/plasmacutter/plasmacutter = tool
			if(!plasmacutter.slice(user))
				return TRUE
		prepared = TRUE
		user.visible_message(
			SPAN_NOTICE("[user] partially cuts through [src] with [tool]."),
			SPAN_NOTICE("You partially cut through [src] with [tool].")
		)
		return TRUE

	return ..()


/obj/structure/mech_wreckage/Destroy()
	for(var/obj/thing in contents)
		if(prob(65))
			thing.forceMove(get_turf(src))
		else
			qdel(thing)
	..()
