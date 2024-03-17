/mob/living/MouseDrop(atom/over)
	if(usr == src && usr != over)
		if(istype(over, /mob/living/exosuit))
			var/mob/living/exosuit/exosuit = over
			if(exosuit.enter(src))
				return
	return ..()

/mob/living/exosuit/MouseDrop_T(atom/dropping, mob/user)
	var/obj/machinery/portable_atmospherics/canister/C = dropping
	if(istype(C))
		body.MouseDrop_T(dropping, user)
	else . = ..()

/mob/living/exosuit/MouseDrop(mob/living/carbon/human/over_object) //going from assumption none of previous options are relevant to exosuit
	if(body)
		if(!body.MouseDrop(over_object))
			return ..()

/mob/living/exosuit/RelayMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, mob/user)
	if(user && (user in pilots) && user.loc == src)
		return OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, user)
	return ..()

/mob/living/exosuit/OnMouseDrag(src_object, over_object, src_location, over_location, src_control, over_control, params, mob/user)
	if(!user || incapacitated() || user.incapacitated())
		return FALSE

	if(!(user in pilots) && user != src)
		return FALSE

	//This is handled at active module level really, it is the one who has to know if it's supposed to act
	if(selected_system)
		return selected_system.MouseDragInteraction(src_object, over_object, src_location, over_location, src_control, over_control, params, user)

/datum/click_handler/default/mech/OnClick(atom/A, params)
	var/mob/living/exosuit/E = user.loc
	if(!istype(E))
		//If this happens something broke tbh
		user.RemoveClickHandler(src)
		return
	if(E.hatch_closed)
		return E.ClickOn(A, params, user)
	else return ..()

/datum/click_handler/default/mech/OnDblClick(atom/A, params)
	OnClick(A, params)

/mob/living/exosuit/allow_click_through(atom/A, params, mob/user)
	if(LAZYISIN(pilots, user) && !hatch_closed)
		return TRUE
	. = ..()

//UI distance checks
/mob/living/exosuit/contents_nano_distance(src_object, mob/living/user)
	. = ..()
	if(!hatch_closed)
		return max(shared_living_nano_distance(src_object), .) //Either visible to mech(outside) or visible to user (inside)


/mob/living/exosuit/ClickOn(atom/A, params, mob/user)

	if(!user || incapacitated() || user.incapacitated())
		return

	if(!loc) return
	var/adj = A.Adjacent(src) // Why in the fuck isn't Adjacent() commutative.

	var/list/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		examinate(user, A)
		return

	if(LAZYACCESS(modifiers, CTRL_CLICK))
		if(istype(A, /obj/item/mech_equipment))
			for(var/hardpoint in hardpoints)
				if(A == hardpoints[hardpoint])
					A.CtrlClick(user)
					setClickCooldown(3)
					return

	if(!(user in pilots) && user != src)
		return

	if(!canClick())
		return

	// Are we facing the target?
	if(A.loc != src && !(get_dir(src, A) & dir))
		return

	if(!arms)
		to_chat(user, SPAN_WARNING("[src] has no manipulators!"))
		setClickCooldown(3)
		return

	if(!arms.motivator || !arms.motivator.is_functional())
		to_chat(user, SPAN_WARNING("Your motivators are damaged! You can't use your manipulators!"))
		setClickCooldown(15)
		return

	if(!get_cell()?.checked_use(arms.power_use * CELLRATE))
		to_chat(user, power == MECH_POWER_ON ? SPAN_WARNING("Error: Power levels insufficient.") :  SPAN_WARNING("[src] is powered off."))
		return

	// User is not necessarily the exosuit, or the same person, so update intent.
	if(user != src)
		a_intent = user.a_intent
		if(user.zone_sel)
			zone_sel.set_selected_zone(user.zone_sel.selecting)
		else
			zone_sel.set_selected_zone(BP_CHEST)
	// You may attack the target with your exosuit FIST if you're malfunctioning.
	var/atom/movable/AM = A
	var/fail_prob = (user != src && istype(AM) && AM.loc != src) ? (user.skill_check(SKILL_MECH, HAS_PERK) ? 0: 15 ) : 0
	var/failed = FALSE
	if(prob(fail_prob))
		to_chat(user, SPAN_DANGER("Your incompetence leads you to target the wrong thing with the exosuit!"))
		failed = TRUE
	else if(emp_damage > EMP_ATTACK_DISRUPT && prob(emp_damage*2))
		to_chat(user, SPAN_DANGER("The wiring sparks as you attempt to control the exosuit!"))
		failed = TRUE

	if(!failed)
		if(istype(A, /obj/item/mech_equipment))
			for(var/hardpoint in hardpoints)
				if(A == hardpoints[hardpoint])
					var/obj/item/mech_equipment/mech_equipment = A
					mech_equipment.attack_self(user)
					setClickCooldown(5)
					return
		if(selected_system)
			// Mounted non-exosuit systems have some hacky loc juggling
			// to make sure that they work.
			var/system_moved = FALSE
			var/obj/item/temp_system
			var/obj/item/mech_equipment/ME
			if(istype(selected_system, /obj/item/mech_equipment))
				ME = selected_system
				temp_system = ME.get_effective_obj()
				if(temp_system in ME)
					system_moved = 1
					temp_system.forceMove(src)
			else
				temp_system = selected_system

			// Slip up and attack yourself maybe.
			failed = FALSE
			if(prob(fail_prob))
				to_chat(user, SPAN_DANGER("You artlessly shove the exosuit controls the wrong way!"))
				failed = TRUE
			else if(emp_damage>EMP_MOVE_DISRUPT && prob(10))
				failed = TRUE

			if(failed)
				var/list/other_atoms = orange(1, A)
				A = null
				while(LAZYLEN(other_atoms))
					var/atom/picked = pick_n_take(other_atoms)
					if(istype(picked) && picked.simulated)
						A = picked
						break
				if(!A)
					A = src
				adj = A.Adjacent(src)

			var/resolved

			if(adj) resolved = temp_system.resolve_attackby(A, src, params)
			if(!resolved && A && temp_system)
				var/mob/ruser = src
				if(!system_moved) //It's more useful to pass along clicker pilot when logic is fully mechside
					ruser = user
				temp_system.afterattack(A,ruser,adj,params)
			if(system_moved) //We are using a proxy system that may not have logging like mech equipment does
				admin_attack_log(user, A, "Attacked using [temp_system] (MECH)", "Was attacked with [temp_system] (MECH)", "used [temp_system] (MECH) to attack")
			//Mech equipment subtypes can add further click delays
			var/extra_delay = 0
			if(!isnull(selected_system))
				ME = selected_system
				extra_delay = ME.equipment_delay
			setClickCooldown(arms ? arms.action_delay + extra_delay : 15 + extra_delay)
			if(system_moved)
				temp_system.forceMove(selected_system)
			return

	if(A == src)
		setClickCooldown(5)
		return attack_self(user)
	else if(adj && user.a_intent == I_HURT) //Prevents accidental slams.
		setClickCooldown(arms ? arms.action_delay : 7) // You've already commited to applying fist, don't turn and back out now!
		playsound(src.loc, legs.mech_step_sound, 60, 1)
		src.visible_message(SPAN_DANGER("[src] steps back, preparing for a slam!"), blind_message = SPAN_DANGER("You hear the loud hissing of hydraulics!"))
		if (do_after(src, 1.2 SECONDS, get_turf(src), DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS) && user)
			A.attack_generic(src, arms.melee_damage, "slammed against", DAMAGE_BRUTE) //"Punch" would be bad since vehicles without arms could be a thing
			var/turf/T = get_step(get_turf(src), src.dir)
			if(istype(T))
				do_attack_effect(T, "smash")
			playsound(src.loc, arms.punch_sound, 50, 1)
	else if(istype(A, /obj/structure/ladder))
		var/obj/structure/ladder/L = A
		L.climb(src) //Those are some real sturdy ladders.
	return

/mob/living/exosuit/proc/set_hardpoint(hardpoint_tag)
	clear_selected_hardpoint()
	if(hardpoints[hardpoint_tag])
		// Set the new system.
		selected_system = hardpoints[hardpoint_tag]
		selected_hardpoint = hardpoint_tag
		return 1 // The element calling this proc will set its own icon.
	return 0

/mob/living/exosuit/proc/clear_selected_hardpoint()

	if(selected_hardpoint)
		for(var/hardpoint in hardpoints)
			if(hardpoint != selected_hardpoint)
				continue
			var/obj/screen/exosuit/hardpoint/H = hardpoint_hud_elements[hardpoint]
			if(istype(H))
				H.icon_state = "hardpoint"
				break
		selected_system = null
	selected_hardpoint = null

/mob/living/exosuit/proc/check_enter(mob/user, silent = FALSE, check_incap = TRUE)
	if(!user || (check_incap && user.incapacitated()))
		return FALSE
	if (user.buckled)
		if (!silent)
			to_chat(user, SPAN_WARNING("You are currently buckled to [user.buckled]."))
		return FALSE
	if(!(user.mob_size >= body.min_pilot_size && user.mob_size <= body.max_pilot_size))
		if(!silent)
			to_chat(user, SPAN_WARNING("You cannot pilot an exosuit of this size."))
		return FALSE
	if(!user.Adjacent(src))
		return FALSE
	if(hatch_locked)
		if(!silent)
			to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
		return FALSE
	if(hatch_closed)
		if(!silent)
			to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is closed."))
		return FALSE
	if(LAZYLEN(pilots) >= LAZYLEN(body.pilot_positions))
		if(!silent)
			to_chat(user, SPAN_WARNING("[src] is occupied to capacity."))
		return FALSE
	return TRUE

/mob/living/exosuit/proc/enter(mob/user, silent = FALSE, check_incap = TRUE, instant = FALSE)
	if(!check_enter(user, silent, check_incap))
		return FALSE
	to_chat(user, SPAN_NOTICE("You start climbing into [src]..."))
	if(!body)
		return FALSE
	if(!instant && !do_after(user, body.climb_time, src, DO_PUBLIC_UNIQUE))
		return FALSE
	if(!check_enter(user, silent, check_incap))
		return FALSE
	if(!silent)
		to_chat(user, SPAN_NOTICE("You climb into [src]."))
		playsound(src, 'sound/machines/airlock_heavy.ogg', 60, 1)
	add_pilot(user)
	return TRUE

/// Adds a mob to the pilots list and destroyed event handlers.
/mob/living/exosuit/proc/add_pilot(mob/user)
	if (LAZYISIN(pilots, user))
		return
	user.forceMove(src)
	user.PushClickHandler(/datum/click_handler/default/mech)
	if (user.client)
		user.client.screen |= hud_elements
	LAZYADD(pilots, user)
	LAZYDISTINCTADD(user.additional_vision_handlers, src)
	GLOB.destroyed_event.register(user, src, PROC_REF(remove_pilot))
	sync_access()
	update_pilots()

/// Removes a mob from the pilots list and destroyed event handlers. Called by the destroyed event.
/mob/living/exosuit/proc/remove_pilot(mob/user)
	if (!LAZYISIN(pilots, user))
		return
	user.RemoveClickHandler(/datum/click_handler/default/mech)
	if (!QDELETED(user))
		user.dropInto(loc)
	if (user.client)
		user.client.screen -= hud_elements
		user.client.eye = user
	LAZYREMOVE(user.additional_vision_handlers, src)
	LAZYREMOVE(pilots, user)
	GLOB.destroyed_event.unregister(user, src, PROC_REF(remove_pilot))
	sync_access()
	update_pilots()

/mob/living/exosuit/proc/sync_access()
	access_card.access = saved_access.Copy()
	if(sync_access)
		for(var/mob/pilot in pilots)
			access_card.access |= pilot.GetAccess()
			to_chat(pilot, SPAN_NOTICE("Security access permissions synchronized."))

/mob/living/exosuit/proc/eject(mob/user, silent)
	if(!user || !(user in src.contents))
		return
	if(hatch_closed)
		if(hatch_locked)
			if(!silent)
				to_chat(user, SPAN_WARNING("The [body.hatch_descriptor] is locked."))
			return
		hud_open.toggled()
		if(!silent)
			to_chat(user, SPAN_NOTICE("You open the hatch and climb out of [src]."))
	else
		if(!silent)
			to_chat(user, SPAN_NOTICE("You climb out of [src]."))

	remove_pilot(user)
	return 1

/mob/living/exosuit/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	// Crowbar - Force open locked cockpit
	if(!body)
		USE_FEEDBACK_FAILURE("[src] has no cockpit to force.")
		return
	if(!hatch_locked)
		USE_FEEDBACK_FAILURE("[src]'s cockpit isn't locked. You don't need to force it.")
		return
	user.visible_message(
		SPAN_WARNING("[user] starts forcing [src]'s emergency [body.hatch_descriptor] release using [tool]."),
		SPAN_WARNING("You start forcing [src]'s emergency [body.hatch_descriptor] release using [tool].")
	)
	if(!tool.use_as_tool(src, user, 5 SECONDS, volume = 50, skill_path = list(SKILL_DEVICES, SKILL_EVA), do_flags = DO_REPAIR_CONSTRUCT) || !body)
		return
	playsound(src, 'sound/machines/bolts_up.ogg', 25, TRUE)
	hatch_locked = FALSE
	hatch_closed = FALSE
	for(var/mob/pilot in pilots)
		eject(pilot, TRUE)
	hud_open.update_icon()
	update_icon()
	user.visible_message(
		SPAN_WARNING("[user] forces [src]'s emergency [body.hatch_descriptor] release using [tool]."),
		SPAN_WARNING("You force [src]'s emergency [body.hatch_descriptor] release using [tool].")
	)

/mob/living/exosuit/multitool_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(hardpoints_locked)
		USE_FEEDBACK_FAILURE("[src]'s hardpoint system is locked.")
		return
	var/list/parts = list()
	for(var/hardpoint in hardpoints)
		if(hardpoints[hardpoint])
			parts += hardpoint
	var/input = input(user, "Which component would you like to remove?", "[src] - Remove Hardpoint") as null|anything in parts
	if(!input || !user.use_sanity_check(src, tool))
		return
	if(isnull(hardpoints[input]))
		USE_FEEDBACK_FAILURE("[src] not longer has a component in the [input] slot.")
		return
	remove_system(input, user)

/mob/living/exosuit/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!maintenance_protocols)
		USE_FEEDBACK_FAILURE("[src]'s maintenance protocols must be enabled to access the power cell.")
		return
	if(!body?.cell)
		USE_FEEDBACK_FAILURE("[src] has no power cell to remove.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts removing [src]'s power cell with [tool]."),
		SPAN_NOTICE("You start removing [src]'s power cell with [tool].")
	)
	if(!tool.use_as_tool(src, user, 2 SECONDS, volume = 50, skill_path = SKILL_DEVICES, do_flags = DO_REPAIR_CONSTRUCT) || !maintenance_protocols || !body?.cell)
		return
	user.put_in_hands(body.cell)
	power = MECH_POWER_OFF
	hud_power_control.update_icon()
	body.cell = null
	user.visible_message(
		SPAN_NOTICE("[user] removes [src]'s power cell with [tool]."),
		SPAN_NOTICE("You remove [src]'s power cell with [tool].")
	)

/mob/living/exosuit/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!maintenance_protocols)
		USE_FEEDBACK_FAILURE("[src]'s maintenance protocols must be enabled to access the securing bolts.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts removing [src]'s securing bolts with [tool]."),
		SPAN_NOTICE("You start removing [src]'s securing bolts with [tool].")
	)
	if(!tool.use_as_tool(src, user, 6 SECONDS, volume = 50, skill_path = SKILL_DEVICES, do_flags = DO_REPAIR_CONSTRUCT) || !maintenance_protocols)
		return
	user.visible_message(
		SPAN_NOTICE("[user] removes [src]'s securing bolts with [tool], dismantling it."),
		SPAN_NOTICE("You remove [src]'s securing bolts with [tool], dismantling it.")
	)
	dismantle()

/mob/living/exosuit/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!getBruteLoss())
		USE_FEEDBACK_NOTHING_TO_REPAIR(user)
		return
	var/list/damaged_parts = list()
	for(var/obj/item/mech_component/component in list(arms, legs, body, head))
		if(component?.brute_damage)
			damaged_parts += component
	var/obj/item/mech_component/input_fix = input(user, "Which component would you like to fix?", "[src] - Fix Component") as null|anything in damaged_parts
	if(!input_fix || !user.use_sanity_check(src, tool))
		return
	if(!input_fix.brute_damage)
		balloon_alert(user, "больше не нуждается в ремонте!")
		return
	input_fix.repair_brute_generic(tool, user)

/mob/living/exosuit/use_tool(obj/item/tool, mob/user, list/click_params)
	// Cable Coil - Repair burn damage
	if (isCoil(tool))
		if (!getFireLoss())
			USE_FEEDBACK_FAILURE("[src] has no electrical damage to repair.")
			return TRUE
		var/list/damaged_parts = list()
		for (var/obj/item/mech_component/component in list(arms, legs, body, head))
			if (component?.burn_damage)
				damaged_parts += component
		var/obj/item/mech_component/input_fix = input(user, "Which component would you like to fix?", "[src] - Fix Component") as null|anything in damaged_parts
		if (!input_fix || !user.use_sanity_check(src, tool))
			return TRUE
		if (!input_fix.burn_damage)
			USE_FEEDBACK_FAILURE("[src]'s [input_fix.name] no longer needs repair.")
			return TRUE
		input_fix.repair_burn_generic(tool, user)
		return TRUE

	// Exosuit Customization Kit - Customize the exosuit
	if (istype(tool, /obj/item/device/kit/paint))
		var/obj/item/device/kit/paint/paint = tool
		SetName(paint.new_name)
		desc = paint.new_desc
		for (var/obj/item/mech_component/component in list(arms, legs, head, body))
			component.decal = paint.new_icon
		if (paint.new_icon_file)
			icon = paint.new_icon_file
		update_icon()
		paint.use(1, user)
		user.visible_message(
			SPAN_NOTICE("[user] opens [tool] and spends some quality time customising [src]."),
			SPAN_NOTICE("You open [tool] and spend some quality time customising [src].")
		)
		return TRUE

	// Mech Equipment - Install equipment
	if (istype(tool, /obj/item/mech_equipment))
		if (hardpoints_locked)
			USE_FEEDBACK_FAILURE("[src]'s hardpoint system is locked.")
			return TRUE
		var/obj/item/mech_equipment/mech_equipment = tool
		if (mech_equipment.owner)
			USE_FEEDBACK_FAILURE("[tool] is already owned by [mech_equipment.owner]. This might be a bug.")
			return TRUE
		var/free_hardpoints = list()
		for (var/hardpoint in hardpoints)
			if (isnull(hardpoints[hardpoint]) && (!length(mech_equipment.restricted_hardpoints) || (hardpoint in mech_equipment.restricted_hardpoints)))
				free_hardpoints += hardpoint
		if (!length(free_hardpoints))
			USE_FEEDBACK_FAILURE("[src] has no free hardpoints for [tool].")
			return TRUE
		var/input = input(user, "Where would you like to install [tool]?", "[src] - Hardpoint Installation") as null|anything in free_hardpoints
		if (!input || !user.use_sanity_check(src, tool, SANITY_CHECK_DEFAULT | SANITY_CHECK_TOOL_UNEQUIP))
			return TRUE
		if (hardpoints[input] != null)
			USE_FEEDBACK_FAILURE("[input] slot on [src] is no longer free. It has [hardpoints[input]] attached.")
			return TRUE
		install_system(tool, input, user)
		return TRUE

	// Power Cell - Install cell
	if (istype(tool, /obj/item/cell))
		if (!maintenance_protocols)
			USE_FEEDBACK_FAILURE("[src]'s maintenance protocols must be enabled to install [tool].")
			return TRUE
		if (body?.cell)
			USE_FEEDBACK_FAILURE("[src] already has [body.cell] installed.")
			return TRUE
		if (!user.unEquip(tool, body))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		body.cell = tool
		playsound(src, 'sound/items/Screwdriver.ogg', 50, TRUE)
		user.visible_message(
			SPAN_NOTICE("[user] installs [tool] into [src]."),
			SPAN_NOTICE("You install [tool] into [src].")
		)
		return TRUE

	return ..()


/mob/living/exosuit/attack_hand(mob/user)
	// Drag the pilot out if possible.
	if(user.a_intent == I_HURT)
		if(!LAZYLEN(pilots))
			to_chat(user, SPAN_WARNING("There is nobody inside [src]."))
		else if(!hatch_closed)
			var/mob/pilot = pick(pilots)
			user.visible_message(SPAN_DANGER("[user] is trying to pull [pilot] out of [src]!"))
			if(do_after(user, 3 SECONDS, src, DO_PUBLIC_UNIQUE) && user.Adjacent(src) && (pilot in pilots) && !hatch_closed)
				user.visible_message(SPAN_DANGER("[user] drags [pilot] out of [src]!"))
				eject(pilot, silent=1)
		else if(hatch_closed)
			if(MUTATION_FERAL in user.mutations)
				attack_generic(user, 5, "slams")
				user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN*2)
		return

	// Otherwise toggle the hatch.
	if(hud_open)
		hud_open.toggled()
	return

/mob/living/exosuit/attack_generic(mob/user, damage, attack_message = "smashes into")
	..()
	if(damage)
		playsound(loc, body.damage_sound, 40, 1)

/mob/living/exosuit/proc/attack_self(mob/user)
	return visible_message("[src] pokes itself.")

/mob/living/exosuit/proc/rename(mob/user)
	if(user != src && !(user in pilots))
		return
	var/new_name = sanitize(input("Enter a new exosuit designation.", "Exosuit Name") as text|null, max_length = MAX_NAME_LEN)
	if(!new_name || new_name == name || (user != src && !(user in pilots)))
		return
	SetName(new_name)
	to_chat(user, SPAN_NOTICE("You have redesignated this exosuit as [name]."))

/mob/living/exosuit/get_inventory_slot(obj/item/I)
	for(var/h in hardpoints)
		if(hardpoints[h] == I)
			return h
	return 0
