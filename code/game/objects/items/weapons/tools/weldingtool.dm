/obj/item/weldingtool
	name = "welding tool"
	icon = 'icons/obj/tools/welder.dmi'
	icon_state = "welder"
	item_state = "welder"
	desc = "A portable welding gun with a port for attaching fuel tanks."
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	center_of_mass = "x=14;y=15"
	waterproof = FALSE
	force = 5
	throwforce = 5
	throw_speed = 1
	throw_range = 5
	w_class = ITEM_SIZE_SMALL
	matter = list(MATERIAL_STEEL = 70, MATERIAL_GLASS = 30)
	origin_tech = list(TECH_ENGINEERING = 1)
	tool_behaviour = TOOL_WELDER
	usesound = DEFAULT_WELDER_SOUND

	var/welding = 0 	//Whether or not the welding tool is off(0), on(1) or currently welding(2)
	var/status = 1 		//Whether the welder is secured or unsecured (able to attach rods to it to make a flamethrower)
	var/welding_resource = "welding fuel"
	var/obj/item/welder_tank/tank = /obj/item/welder_tank // where the fuel is stored

/obj/item/weldingtool/Initialize()
	if(ispath(tank))
		tank = new tank
		w_class = tank.size_in_use
		force = tank.unlit_force

	set_extension(src, /datum/extension/base_icon_state, icon_state)
	update_icon()

	. = ..()

/obj/item/weldingtool/Destroy()
	if(welding)
		STOP_PROCESSING(SSobj, src)

	QDEL_NULL(tank)

	return ..()

/obj/item/weldingtool/examine(mob/user, distance)
	. = ..()
	if (!tank)
		to_chat(user, "There is no [welding_resource] source attached.")
	else
		to_chat(user, (distance <= 1 ? "It has [get_fuel()] [welding_resource] remaining. " : "") + "[tank] is attached.")

/obj/item/weldingtool/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 10, do_flags = DO_REPAIR_CONSTRUCT))
		return
	status = !status
	if(status)
		to_chat(user, SPAN_NOTICE("You secure the welder."))
	else
		to_chat(user, SPAN_NOTICE("The welder can now be attached and modified."))
	add_fingerprint(user)

/obj/item/weldingtool/attackby(obj/item/W as obj, mob/user as mob)
	if(welding)
		to_chat(user, SPAN_DANGER("Stop welding first!"))
		return

	if((!status) && (istype(W,/obj/item/stack/material/rods)))
		var/obj/item/stack/material/rods/R = W
		R.use(1)
		var/obj/item/flamethrower/F = new/obj/item/flamethrower(user.loc)
		user.drop_from_inventory(src, F)
		F.weldtool = src
		master = F
		add_fingerprint(user)
		return

	if (istype(W, /obj/item/welder_tank))
		if (tank)
			to_chat(user, SPAN_WARNING("[src] already has a tank attached - remove it first."))
			return
		if (user.get_active_hand() != src && user.get_inactive_hand() != src)
			to_chat(user, SPAN_WARNING("You must hold the welder in your hands to attach a tank."))
			return
		if (!user.unEquip(W, src))
			return
		tank = W
		user.visible_message("[user] slots [W] into [src].", "You slot [W] into [src].")
		w_class = tank.size_in_use
		force = tank.unlit_force
		playsound(src, 'sound/items/cap_close.ogg', 10, 1)
		update_icon()
		return

	..()


/obj/item/weldingtool/attack_hand(mob/user as mob)
	if (tank && user.get_inactive_hand() == src)
		if (!welding)
			user.visible_message("[user] removes [tank] from [src].", "You remove [tank] from [src].")
			user.put_in_hands(tank)
			tank = null
			w_class = initial(w_class)
			force = initial(force)
			playsound(src, 'sound/items/cap_open.ogg', 10, 1)
			update_icon()
		else
			to_chat(user, SPAN_DANGER("Turn off the welder first!"))

	else
		..()

/obj/item/weldingtool/water_act()
	if(welding && !waterproof)
		setWelding(0)

/obj/item/weldingtool/Process()
	if(welding)
		if((!waterproof && submerged()))
			setWelding(0)

/obj/item/weldingtool/use_after(obj/O, mob/living/user)
	if(istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src,O) <= 1 && !welding)
		if(!tank)
			to_chat(user, SPAN_WARNING("[src] has no tank attached!"))
			return TRUE
		if (!tank.can_refuel)
			to_chat(user, SPAN_WARNING("[tank] does not have a refuelling port."))
			return TRUE
		O.reagents.trans_to_obj(tank, tank.max_fuel)
		to_chat(user, SPAN_NOTICE("You refuel [tank]."))
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return TRUE

	if(welding)
		var/turf/location = get_turf(user)
		if(isliving(O))
			var/mob/living/L = O
			L.IgniteMob()
		else if(istype(O))
			O.HandleObjectHeating(src, user, 700)
		if (istype(location, /turf))
			location.hotspot_expose(700, 50, 1)
	return

/obj/item/weldingtool/attack_self(mob/user)
	setWelding(!welding, user)
	return

//Returns the amount of fuel in the welder
/obj/item/weldingtool/proc/get_fuel()
	return tank ? tank.reagents.get_reagent_amount(/datum/reagent/fuel) : 0

/// Turns off the welder if there is no more fuel (does this really need to be its own proc?)
/obj/item/weldingtool/proc/check_fuel(mob/user)
	if(get_fuel() <= 0 && welding)
		setWelding(FALSE, user)
		return FALSE
	return TRUE

/// Uses fuel from the welding tool.
/obj/item/weldingtool/use(used = 0)
	if(!isOn() || !check_fuel())
		return FALSE

	if(get_fuel() >= used)
		burn_fuel(used)
		check_fuel()
		return TRUE
	else
		return FALSE

/// If welding tool ran out of fuel during a construction task, construction fails.
/obj/item/weldingtool/tool_use_check(mob/living/user, amount)
	if(!isOn() || !check_fuel())
		to_chat(user, SPAN_WARNING("[src] has to be on to complete this task!"))
		return FALSE

	if(get_fuel() >= amount)
		if(user)
			user.welding_eyecheck()//located in mob_helpers.dm
			set_light(5, 0.7, COLOR_LIGHT_CYAN)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom, update_icon)), 0.5 SECONDS)
		return TRUE
	else
		to_chat(user, SPAN_WARNING("You need more welding fuel to complete this task!"))
		return FALSE

/obj/item/weldingtool/proc/burn_fuel(amount)
	if(!tank)
		return

	var/mob/living/in_mob = null

	//consider ourselves in a mob if we are in the mob's contents and not in their hands
	if(isliving(src.loc))
		var/mob/living/L = src.loc
		if (!L.IsHolding(src))
			in_mob = L

	if(in_mob)
		amount = max(amount, 2)
		tank.reagents.trans_type_to(in_mob, /datum/reagent/fuel, amount)
		in_mob.IgniteMob()

	else
		tank.reagents.remove_reagent(/datum/reagent/fuel, amount)
		var/turf/location = get_turf(src.loc)
		if(location)
			location.hotspot_expose(700, 5)

//Returns whether or not the welding tool is currently on.
/obj/item/weldingtool/proc/isOn()
	return welding

/obj/item/weldingtool/get_storage_cost()
	if(isOn())
		return ITEM_SIZE_NO_CONTAINER
	return ..()

/obj/item/weldingtool/on_update_icon()
	..()
	ClearOverlays()
	if(tank)
		AddOverlays(image('icons/obj/tools/welder.dmi', "welder_[tank.icon_state]"))
	if(welding)
		AddOverlays(image('icons/obj/tools/welder.dmi', "welder_on"))
		set_light(2.5, 0.6, l_color =COLOR_PALE_ORANGE)
	else
		set_light(0)
	item_state = welding ? "welder1" : "welder"
	var/mob/M = loc
	if(istype(M))
		M.update_inv_l_hand()
		M.update_inv_r_hand()

//Sets the welding state of the welding tool. If you see W.welding = 1 anywhere, please change it to W.setWelding(1)
//so that the welding tool updates accordingly
/obj/item/weldingtool/proc/setWelding(set_welding, mob/M)
	if (!status)
		return

	if(!welding && !waterproof && submerged())
		if(M)
			to_chat(M, SPAN_WARNING("You cannot light [src] underwater."))
		return

	var/turf/T = get_turf(src)
	//If we're turning it on
	if(set_welding && !welding)
		if (get_fuel() > 0)
			if(M)
				to_chat(M, SPAN_NOTICE("You switch the [src] on."))
			else if(T)
				T.visible_message(SPAN_WARNING("[src] turns on."))
			if (istype(src, /obj/item/weldingtool/electric))
				src.force = 11
				src.damtype = DAMAGE_SHOCK
			else
				src.force = tank.lit_force
				src.damtype = DAMAGE_BURN
			welding = 1
			playsound(src, 'sound/items/welderactivate.ogg', 10, 1)
			update_icon()
			START_PROCESSING(SSobj, src)
		else
			if(M)
				to_chat(M, SPAN_NOTICE("You need more [welding_resource] to complete this task."))
			return
	//Otherwise
	else if(!set_welding && welding)
		STOP_PROCESSING(SSobj, src)
		if(M)
			to_chat(M, SPAN_NOTICE("You switch [src] off."))
		else if(T)
			T.visible_message(SPAN_WARNING("[src] turns off."))
		if (istype(src, /obj/item/weldingtool/electric))
			src.force = initial(force)
		else
			src.force = tank.unlit_force
		src.damtype = DAMAGE_BRUTE
		src.welding = 0
		playsound(src, 'sound/items/welderdeactivate.ogg', 10, 1)
		update_icon()

/obj/item/weldingtool/use_before(mob/living/target, mob/living/user, click_parameters)
	if (!ishuman(target))
		return FALSE

	var/target_zone = user.zone_sel.selecting
	var/mob/living/carbon/human/H = target
	var/obj/item/organ/external/S = H.organs_by_name[target_zone]

	if (!S || !BP_IS_ROBOTIC(S) || user.a_intent != I_HELP)
		return FALSE

	var/list/all_surgeries = GET_SINGLETON_SUBTYPE_MAP(/singleton/surgery_step)
	for (var/singleton in all_surgeries)
		var/singleton/surgery_step/step = all_surgeries[singleton]
		if (step.name && step.tool_quality(src) && step.can_use(user, H, target_zone, src))
			return FALSE

	if (BP_IS_BRITTLE(S))
		to_chat(user, SPAN_WARNING("[target]'s [S.name] is hard and brittle - [src] cannot repair it."))
		return TRUE

	if (!tool_start_check(user, 2)) //The surgery check above already returns can_use's feedback.
		return TRUE

	if (S.robo_repair(15, DAMAGE_BRUTE, "some dents", src, user))
		use(2)
		return TRUE

	else return FALSE

/obj/item/weldingtool/IsFlameSource()
	return isOn()


/obj/item/weldingtool/IsHeatSource()
	return isOn() ? 3800 : 0


/obj/item/weldingtool/mini
	tank = /obj/item/welder_tank/mini

/obj/item/weldingtool/largetank
	tank = /obj/item/welder_tank/large

/obj/item/weldingtool/hugetank
	tank = /obj/item/welder_tank/huge

/obj/item/weldingtool/experimental
	tank = /obj/item/welder_tank/experimental

///////////////////////
//Welding tool tanks//
/////////////////////
/obj/item/welder_tank
	name = "\improper welding fuel tank"
	desc = "An interchangeable fuel tank meant for a welding tool."
	icon = 'icons/obj/tools/welder.dmi'
	icon_state = "tank_normal"
	w_class = ITEM_SIZE_SMALL
	force = 5
	throwforce = 5
	var/max_fuel = 20
	var/can_refuel = 1
	var/size_in_use = ITEM_SIZE_NORMAL
	var/unlit_force = 7
	var/lit_force = 11

/obj/item/welder_tank/Initialize()
	create_reagents(max_fuel)
	reagents.add_reagent(/datum/reagent/fuel, max_fuel)
	. = ..()

/obj/item/welder_tank/use_after(obj/O, mob/living/user, click_parameters)
	if (istype(O, /obj/structure/reagent_dispensers/fueltank) && get_dist(src, O) <= 1)
		if (!can_refuel)
			to_chat(user, SPAN_DANGER("[src] does not have a refuelling port."))
			return TRUE
		O.reagents.trans_to_obj(src, max_fuel)
		to_chat(user, SPAN_NOTICE("You refuel [src]."))
		playsound(src.loc, 'sound/effects/refill.ogg', 50, 1, -6)
		return TRUE

/obj/item/welder_tank/mini
	name = "small welding fuel tank"
	icon_state = "tank_small"
	w_class = ITEM_SIZE_TINY
	max_fuel = 5
	force = 4
	throwforce = 4
	size_in_use = ITEM_SIZE_SMALL
	unlit_force = 5
	lit_force = 7

/obj/item/welder_tank/large
	name = "large welding fuel tank"
	icon_state = "tank_large"
	w_class = ITEM_SIZE_SMALL
	max_fuel = 40
	force = 6
	throwforce = 6
	size_in_use = ITEM_SIZE_NORMAL


/obj/item/welder_tank/huge
	name = "huge welding fuel tank"
	icon_state = "tank_huge"
	w_class = ITEM_SIZE_NORMAL
	max_fuel = 80
	force = 8
	throwforce = 8
	size_in_use = ITEM_SIZE_LARGE
	unlit_force = 9
	lit_force = 15

/obj/item/welder_tank/experimental
	name = "experimental welding fuel tank"
	icon_state = "tank_experimental"
	w_class = ITEM_SIZE_NORMAL
	max_fuel = 40
	can_refuel = 0
	force = 8
	throwforce = 8
	size_in_use = ITEM_SIZE_LARGE
	unlit_force = 9
	lit_force = 15
	var/last_gen = 0

/obj/item/welder_tank/experimental/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/welder_tank/experimental/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/welder_tank/experimental/Process()
	var/cur_fuel = reagents.get_reagent_amount(/datum/reagent/fuel)
	if(cur_fuel < max_fuel)
		var/gen_amount = ((world.time-last_gen)/25)
		reagents.add_reagent(/datum/reagent/fuel, gen_amount)
		last_gen = world.time
