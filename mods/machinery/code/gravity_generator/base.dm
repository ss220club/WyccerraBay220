/obj/machinery/gravity_generator
	icon = 'mods/machinery/icons/gravity_generator.dmi'
	icon_state = "0_0"

	var/sprite_number = 0
	var/broken_state = 0

/obj/machinery/gravity_generator/on_update_icon()
	icon_state = "[broken_state]_[sprite_number]"

/obj/machinery/gravity_generator/proc/show_broken_info()
	return

/obj/machinery/gravity_generator/proc/take_damage(amount)
	return


#define POWER_IDLE 0
#define POWER_UP 1
#define POWER_DOWN 2

#define GRAV_NEEDS_PLASTEEL 1
#define GRAV_NEEDS_WELDING 2
#define GRAV_NEEDS_WRENCH 3
#define GRAV_NEEDS_SCREWDRIVER 4

/obj/machinery/gravity_generator/main
	name = "gravitational generator panel"
	icon_state = "0_8"
	idle_power_usage = 0
	active_power_usage = 100000
	power_channel = ENVIRON
	sprite_number = 8
	use_power = POWER_USE_ACTIVE

	var/enabled = TRUE               // for switching gravity status in areas
	var/breaker = TRUE               // if true - charges the GG if it has power
	var/charging_state = POWER_IDLE  // check process()
	var/charge_count = 100           // % of current charge
	var/health = 1000

	var/list/parts = list()
	var/list/lights = list()
	var/list/connected_areas = list()
	var/obj/machinery/gravity_generator/part/middle = null

	// Wires
	var/announcer = TRUE                  // if true - notifies about the switching of the state of the generator to the engineering channel
	var/power_supply = TRUE               // if false - will lose power after proc/update_power()
	var/can_toggle_breaker = TRUE
	var/emergency_shutoff_button = FALSE  // if true - shows an additional option with emergency generator shutdown

/obj/machinery/gravity_generator/main/Initialize()
	. = ..()
	setup_parts()
	update_icon()
	add_areas()
	wires = new/datum/wires/gravity_generator(src)

/obj/machinery/gravity_generator/main/Destroy()
	QDEL_NULL(wires)
	for(var/obj/machinery/gravity_generator/part/P in parts)
		P.main_part = null
		parts -= P
		if(!QDELETED(P))
			qdel(P)
	middle = null
	lights = null
	connected_areas = null
	update_connectected_areas_gravity()
	return ..()

/obj/machinery/gravity_generator/main/examine(mob/user)
	. = ..()
	if(panel_open)
		to_chat(user, "The maintenance hatch is open.")
	show_broken_info(user)

/obj/machinery/gravity_generator/main/show_broken_info(mob/user)
	switch(broken_state)
		if(GRAV_NEEDS_PLASTEEL)
			to_chat(user, "It requires ten plasteel to repair.")
		if(GRAV_NEEDS_WELDING)
			to_chat(user, "It requires a welder to repair.")
		if(GRAV_NEEDS_WRENCH)
			to_chat(user, "It requires a wrench to repair.")
		if(GRAV_NEEDS_SCREWDRIVER)
			to_chat(user, "It requires a screwdriver to repair.")

/obj/machinery/gravity_generator/main/ex_act(severity)
	switch(severity)
		if(1)
			take_damage(rand(750, 1250))
		if(2)
			take_damage(rand(350, 500))
		if(3)
			take_damage(rand(50, 150))

/obj/machinery/gravity_generator/main/emp_act(severity)
	if(!breaker || inoperable())
		return

	if(prob(80 / severity))
		set_state(FALSE)

	set_stat(MACHINE_STAT_EMPED, TRUE)

/obj/machinery/gravity_generator/main/bullet_act(obj/item/projectile/P, def_zone)
	switch(P.damage_type)
		if(INJURY_TYPE_BRUISE)
			take_damage(P.damage)
		if(INJURY_TYPE_BURN)
			take_damage(P.damage)
		if(INJURY_TYPE_PIERCE)
			take_damage(P.damage)
		if(INJURY_TYPE_LASER)
			take_damage(P.damage)
		if(INJURY_TYPE_SHATTER)
			take_damage(P.damage)

/obj/machinery/gravity_generator/main/take_damage(amount)
	var/new_health = max(0, health - amount)
	update_health(new_health)
	update_icon()

/obj/machinery/gravity_generator/main/proc/set_broken_state(state)
	broken_state = state
	for(var/obj/machinery/gravity_generator/part/P in parts)
		P.broken_state = state

/obj/machinery/gravity_generator/main/proc/update_health(new_health)
	if(new_health == health)
		return
	health = new_health
	switch(health)
		if(0)
			charge_count = 0
			enabled = FALSE
			visible_message(SPAN_WARNING("[src] breaks apart!"))
			set_broken_state(GRAV_NEEDS_PLASTEEL)
			set_broken(MACHINE_BROKEN_GENERIC, TRUE)
			set_state(FALSE)
			update_gravity_status()
			update_power()
		if(1 to 249)
			set_broken_state(GRAV_NEEDS_WELDING)
		if(250 to 499)
			set_broken_state(GRAV_NEEDS_WRENCH)
		if(500 to 749)
			set_broken_state(GRAV_NEEDS_SCREWDRIVER)

/obj/machinery/gravity_generator/main/proc/setup_parts()
	var/turf/our_turf = get_turf(src)
	// 9x9 block obtained from the bottom middle of the block
	var/list/spawn_turfs = block(locate(our_turf.x - 1, our_turf.y + 2, our_turf.z), locate(our_turf.x + 1, our_turf.y, our_turf.z))
	var/count = 10
	for(var/turf/T in spawn_turfs)
		count--
		if(T == our_turf) // Skip our turf.
			continue
		var/obj/machinery/gravity_generator/part/P = new(T)
		if(count == 5)
			middle = P
		if(count <= 3) // Their sprite is the top part of the generator
			P.density = FALSE
			P.layer = MOB_LAYER + 0.1
		if(count in list(2, 5, 7, 9))
			lights += P
		P.sprite_number = count
		P.main_part = src
		parts += P

/obj/machinery/gravity_generator/main/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(middle, user, 5 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	panel_open = !panel_open
	update_icon()
	to_chat(user, SPAN_NOTICE("You [panel_open ? "open" : "close"] the maintenance hatch."))

// Fixing the gravity generator.
/obj/machinery/gravity_generator/main/screwdriver_act(mob/living/user, obj/item/tool)
	if(broken_state != GRAV_NEEDS_SCREWDRIVER)
		return
	. = ITEM_INTERACT_SUCCESS
	user.visible_message(
		SPAN_NOTICE("[user] begins to attach the details in the desired order."),
		SPAN_NOTICE("You begin to attach the details in the desired order.")
	)
	if(!tool.use_as_tool(middle, user, 15 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || broken_state != GRAV_NEEDS_SCREWDRIVER)
		return
	health += max(initial(health), health + 250)
	user.visible_message(
		SPAN_NOTICE("[user] attached the details."),
		SPAN_NOTICE("You have attached the details.")
	)
	stat &= ~MACHINE_BROKEN_GENERIC
	set_broken_state(0)
	update_icon()

/obj/machinery/gravity_generator/main/wrench_act(mob/living/user, obj/item/tool)
	if(broken_state != GRAV_NEEDS_WRENCH)
		return
	. = ITEM_INTERACT_SUCCESS
	user.visible_message(
		SPAN_NOTICE("[user] screws the parts back."),
		SPAN_NOTICE("You begin to screw the parts back.")
	)
	if(!tool.use_as_tool(middle, user, 15 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || broken_state != GRAV_NEEDS_WRENCH)
		return
	health += 250
	user.visible_message(
		SPAN_NOTICE("[user] screwed the parts back."),
		SPAN_NOTICE("You screwed the parts back.")
	)
	set_broken_state(GRAV_NEEDS_SCREWDRIVER)
	update_icon()

/obj/machinery/gravity_generator/main/welder_act(mob/living/user, obj/item/tool)
	if(broken_state != GRAV_NEEDS_WELDING)
		return
	. = ITEM_INTERACT_SUCCESS
	if(!tool.tool_start_check(user, 1))
		return
	USE_FEEDBACK_REPAIR_START(user)
	if(!tool.use_as_tool(src, user, 15 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT) || broken_state != GRAV_NEEDS_WELDING)
		return
	health += 250
	USE_FEEDBACK_REPAIR_FINISH(user)
	set_broken_state(GRAV_NEEDS_WRENCH)
	update_icon()

/obj/machinery/gravity_generator/main/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if(broken_state == GRAV_NEEDS_PLASTEEL)
		if(istype(tool, /obj/item/stack/material/plasteel) || broken_state != GRAV_NEEDS_PLASTEEL)
			var/obj/item/stack/material/plasteel/PS = tool
			if(PS.amount < 10)
				to_chat(user, SPAN_WARNING("You need 10 sheets of plasteel."))
				return TRUE

			user.visible_message(
				SPAN_NOTICE("[user] begins to add plasteel to the destroyed frame."),
				SPAN_NOTICE("You begin to add plasteel to the destroyed frame.")
			)
			playsound(loc, 'sound/machines/click.ogg', 75, 1)

			if(!do_after(user, 15 SECONDS, middle) || !user.use_sanity_check(src, tool) || PS.amount < 10)
				return TRUE

			PS.use(10)
			health += 250
			user.visible_message(
				SPAN_NOTICE("[user] replaced the destroyed frame."),
				SPAN_NOTICE("You replaced the destroyed frame.")
			)
			playsound(loc, 'sound/machines/click.ogg', 75, 1)
			set_broken_state(GRAV_NEEDS_WELDING)
			update_icon()
			return TRUE
	return ..()

/obj/machinery/gravity_generator/part/attack_ghost(mob/user)
	ui_interact(user)

/obj/machinery/gravity_generator/main/attack_ai(mob/user)
	if(inoperable())
		return

	ui_interact(user)

/obj/machinery/gravity_generator/main/attack_hand(mob/user)
	if(reason_broken)
		to_chat(user, SPAN_WARNING("[src] is broken!"))
		return

	if(wires && panel_open)
		wires.Interact(user)
		return

	if(!is_powered())
		return

	ui_interact(user)

/obj/machinery/gravity_generator/main/CanUseTopic(mob/user)
	if(!power_supply)
		return STATUS_CLOSE
	if(GET_FLAGS(stat, MACHINE_STAT_EMPED))
		return STATUS_CLOSE
	return ..()

// Interaction
/obj/machinery/gravity_generator/main/ui_interact(mob/user, ui_key, datum/nanoui/ui, force_open, datum/nanoui/master_ui, datum/topic_state/state)
	var/data = list()

	data["enabled"] = enabled
	data["charging_state"] = charging_state
	data["charger_count"] = charge_count
	data["breaker"] = breaker
	data["emergency_shutoff_button"] = emergency_shutoff_button

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "gravgen.tmpl", "Gravitational Generator Panel", 500, 300, state = state)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/gravity_generator/main/OnTopic(mob/user, href_list, datum/topic_state/state)
	if(href_list["gentoggle"])
		if(!can_toggle_breaker || !power_supply || !is_powered())
			to_chat(user, SPAN_WARNING("You pressed a button, but it doesn’t seem to respond."))
			return
		set_state(breaker ? FALSE : TRUE)

	else if(href_list["eshutoff"])
		if(!emergency_shutoff_button)
			return
		if(!charge_count)
			to_chat(user, SPAN_WARNING("[middle] discharged!"))
			return

		user.visible_message(
			SPAN_WARNING("[user] starts to press a lot of buttons on [src]!"),
			SPAN_NOTICE("You start to press many buttons on [src], as if you know what you are doing.")
		)
		if(do_after(user, 15 SECONDS, src))
			emergency_shutoff()

/obj/machinery/gravity_generator/main/proc/emergency_shutoff()
	if(!charge_count)
		return

	var/charge = charge_count
	var/was_enabled = enabled
	charge_count = 0
	toggle_stat(MACHINE_STAT_EMPED)
	enabled = FALSE
	breaker = FALSE
	charging_state = POWER_IDLE
	update_use_power(POWER_USE_IDLE)
	visible_message(SPAN_DANGER("[src] makes a large whirring noise!"))

	for(var/i = 0, i <= 3, i++)
		switch(i)
			if(0)
				set_light(8, 1,"#b30f00")
			if(1)
				set_light(8, 0.75,"#b30f00")
			if(2)
				set_light(8, 0.5,"#b30f00")
			if(3)
				set_light(8, 0.25,"#b30f00")

		playsound(loc, 'sound/effects/EMPulse.ogg', 100, 1)
		sleep(25)

	toggle_stat(MACHINE_STAT_EMPED)
	if(was_enabled)
		update_gravity_status()
	update_icon()

	if(announcer)
		GLOB.global_announcer.autosay("Alert! Gravitational Generator has been discharged! Gravitation is disabled.", "Gravity Generator Alert System")

	SSradiation.radiate(src, 3 * charge)
	playsound(loc, 'sound/effects/EMPulse.ogg', 100, 1)
	empulse(loc, 7 * (charge * 0.01), 14 * (charge * 0.01))

/obj/machinery/gravity_generator/main/on_update_icon()
	. = ..()
	ClearOverlays()
	for(var/obj/machinery/gravity_generator/part/P in lights)
		P.ClearOverlays()

	var/console
	if(power_supply && operable())
		if(charging_state == POWER_IDLE)
			console = charge_count ? "console_charged" : "console_discharged"
		else
			console = "console_charging"
		AddOverlays(console)
		if(breaker)
			for(var/obj/machinery/gravity_generator/part/P in lights)
				P.AddOverlays("[P.sprite_number]_light")

	if(!panel_open)
		if(power_supply && operable())
			AddOverlays("keyboard_on")
		else
			AddOverlays("keyboard_off")

	var/overlay_state
	switch(charge_count)
		if(0 to 20)
			overlay_state = null
			set_light(0)
		if(21 to 40)
			overlay_state = "startup"
			set_light(4, 0.2, "#6496fa")
		if(41 to 60)
			overlay_state = "idle"
			set_light(6, 0.5, "#7d9bff")
		if(61 to 80)
			overlay_state = "activating"
			set_light(6, 0.8, "#7dc3ff")
		if(81 to 100)
			overlay_state = "activated"
			set_light(8, 1, "#7de1e1")

	if(middle)
		middle.ClearOverlays()
		if(overlay_state)
			middle.AddOverlays(overlay_state)

	for(var/obj/machinery/gravity_generator/part/P in parts)
		P.update_icon()

/obj/machinery/gravity_generator/main/power_change()
	. = ..()
	update_power()

// Set the state of the gravity.
/obj/machinery/gravity_generator/main/proc/set_state(new_state)
	breaker = new_state
	update_power()

// Set the charging state based on power/breaker/power_supply(wires) status.
/obj/machinery/gravity_generator/main/proc/update_power()
	var/operable = breaker && power_supply && operable()

	update_use_power(operable ? POWER_USE_ACTIVE : POWER_USE_IDLE)
	if(operable && charge_count < 100)
		charging_state = POWER_UP
	else if(!operable && charge_count > 0)
		charging_state = POWER_DOWN
	else
		charging_state = POWER_IDLE

	update_icon()
	investigate_log("is now [charging_state == POWER_UP ? "charging" : "discharging"].", "gravity")

// Charge/Discharge and turn on/off gravity when you reach 0/100 percent.
// Also emit radiation and handle the overlays.
/obj/machinery/gravity_generator/main/Process()
	if(reason_broken)
		return

	if(charge_count > 0)
		SSradiation.radiate(src, 30 * (charge_count * 0.01))

	if(charging_state != POWER_IDLE)
		update_icon()
		if(prob(75))
			playsound(loc, 'sound/effects/EMPulse.ogg', 50, 1)

	var/last_charge_count = charge_count
	switch(charging_state)
		if(POWER_UP)
			charge_count = min(100, charge_count + 2)

		if(POWER_DOWN)
			charge_count = max(0, charge_count - 2)
			if(announcer && charge_count <= 50 && charge_count % 5 == 0)
				GLOB.global_announcer.autosay("Danger! Gravitational Generator discharges detected! Charge status at [charge_count]%", "Gravity Generator Alert System", "Engineering")

	if(last_charge_count <= 100 && charge_count == 100)
		on_fully_charged()

	else if(last_charge_count > 0 && charge_count == 0)
		on_discharge()

/obj/machinery/gravity_generator/main/proc/on_discharge()
	set_state(FALSE)
	if(!enabled)
		return

	enabled = FALSE
	update_gravity_status()
	playsound(loc, 'sound/effects/alert.ogg', 50, 1)
	if(announcer)
		GLOB.global_announcer.autosay("Alert! Gravitational Generator has been discharged! Gravitation is disabled.", "Gravity Generator Alert System")

/obj/machinery/gravity_generator/main/proc/on_fully_charged()
	set_state(TRUE)
	if(enabled)
		return

	enabled = TRUE

	update_gravity_status()
	playsound(loc, 'sound/effects/alert.ogg', 50, 1)
	if(announcer)
		GLOB.global_announcer.autosay("Gravitational Generator has been fully charged. Gravitation is enabled!", "Gravity Generator Alert System")

/obj/machinery/gravity_generator/main/proc/update_gravity_status()
	shake_everyone()
	update_connectected_areas_gravity()

/obj/machinery/gravity_generator/main/proc/shake_everyone()
	var/list/area_refs_set = get_area_refs_set(connected_areas)
	for(var/mob/living/living_mob as anything in GLOB.living_players)
		if(living_mob.stat)
			continue

		if(!area_refs_set[ref(get_area(living_mob))])
			continue

		shake_camera(living_mob, 5, 1)

/obj/machinery/gravity_generator/main/proc/update_connectected_areas_gravity()
	for(var/area/area_to_update as anything in connected_areas)
		area_to_update.gravitychange(enabled)

/obj/machinery/gravity_generator/main/proc/add_areas()
	connected_areas += get_filtered_areas(list(GLOBAL_PROC_REF(is_not_space_area), GLOBAL_PROC_REF(is_station_area)))

#undef GRAV_NEEDS_SCREWDRIVER
#undef GRAV_NEEDS_WELDING
#undef GRAV_NEEDS_PLASTEEL
#undef GRAV_NEEDS_WRENCH

#undef POWER_IDLE
#undef POWER_UP
#undef POWER_DOWN



/obj/machinery/gravity_generator/part
	var/obj/machinery/gravity_generator/main/main_part = null

/obj/machinery/gravity_generator/part/Destroy()
	if(!QDELETED(main_part))
		main_part.parts -= src
		QDEL_NULL(main_part)
	return ..()

/obj/machinery/gravity_generator/part/examine(mob/user)
	. = ..()
	main_part.show_broken_info(user)

/obj/machinery/gravity_generator/part/use_tool(obj/item/tool, mob/living/user, list/click_params)
	if (main_part)
		return main_part.use_tool(tool, user, click_params)
	return ..()

/obj/machinery/gravity_generator/part/bullet_act(obj/item/projectile/P)
	return main_part.bullet_act(P)
