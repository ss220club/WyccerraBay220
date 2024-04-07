/obj/machinery/atmospherics/pipe/cap/sparker
	name = "pipe sparker"
	desc = "A pipe sparker. Useful for starting pipe fires."
	icon = 'icons/atmos/pipe-sparker.dmi'
	icon_state = "pipe-sparker"
	volume = ATMOS_DEFAULT_VOLUME_PIPE / 2
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_FUEL
	build_icon = 'icons/atmos/pipe-sparker.dmi'
	build_icon_state = "pipe-igniter"
	idle_power_usage = 20

	maximum_pressure = 420*ONE_ATMOSPHERE
	fatigue_pressure = 350*ONE_ATMOSPHERE
	alert_pressure = 350*ONE_ATMOSPHERE

	var/last_spark = 0
	var/disabled = FALSE
	var/obj/item/device/assembly/signaler/signaler = null

	uncreated_component_parts = list(
		/obj/item/stock_parts/radio/receiver,
		/obj/item/stock_parts/power/apc
	)
	public_methods = list(
		/singleton/public_access/public_method/pipe_sparker_spark
	)
	stock_part_presets = list(/singleton/stock_part_preset/radio/receiver/sparker/pipe = 1)

/singleton/public_access/public_method/pipe_sparker_spark
	name = "pipespark"
	desc = "Ignites gas in a pipeline."
	call_proc = TYPE_PROC_REF(/obj/machinery/atmospherics/pipe/cap/sparker, ignite)

/singleton/stock_part_preset/radio/receiver/sparker/pipe
	frequency = GLOB.BUTTON_FREQ
	receive_and_call = list("button_active" = /singleton/public_access/public_method/pipe_sparker_spark)

/obj/machinery/atmospherics/pipe/cap/sparker/visible
	icon_state = "pipe-sparker"

/obj/machinery/atmospherics/pipe/cap/sparker/hidden
	level = ATOM_LEVEL_UNDER_TILE
	icon_state = "pipe-sparker"
	alpha = 128

/obj/machinery/atmospherics/pipe/cap/sparker/proc/cant_ignite()
	if ((world.time < last_spark + 50) || !powered() || disabled)
		return TRUE
	return FALSE

/obj/machinery/atmospherics/pipe/cap/sparker/proc/ignite()
	playsound(loc, 'sound/machines/click.ogg', 10, 1)
	if (cant_ignite())
		return

	playsound(loc, "sparks", 100, 1)
	use_power_oneoff(2000)
	flick("pipe-sparker-spark", src)
	parent.air.react(null, TRUE, TRUE)//full bypass
	last_spark = world.time

/obj/machinery/atmospherics/pipe/cap/sparker/physical_attack_hand(mob/user)
	playsound(loc, "button", 30, 1)
	if (cant_ignite())
		user.visible_message(
			SPAN_NOTICE("[user] tries to activate [src], but nothing happens."),
			SPAN_NOTICE("You try to activate [src], but nothing happens.")
		)
		return
	user.visible_message(
		SPAN_NOTICE("[user] activates [src]."),
		SPAN_NOTICE("You activate [src].")
	)
	ignite()

/obj/machinery/atmospherics/pipe/cap/sparker/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(signaler || disabled)
		to_chat(user, SPAN_NOTICE("Remove signalers and check the wiring before unwrenching [src]."))
		return
	var/turf/T = src.loc
	if(level == ATOM_LEVEL_UNDER_TILE && isturf(T) && !T.is_plating())
		to_chat(user, SPAN_WARNING("You must remove the plating first."))
		return
	if(clamp)
		to_chat(user, SPAN_WARNING("You must remove [clamp] first."))
		return

	var/datum/gas_mixture/int_air = return_air()
	var/datum/gas_mixture/env_air = loc.return_air()

	if((int_air.return_pressure()-env_air.return_pressure()) > 2*ONE_ATMOSPHERE)
		to_chat(user, SPAN_WARNING("You cannot unwrench [src], it is too exerted due to internal pressure."))
		return

	to_chat(user, SPAN_NOTICE("You begin to unfasten [src]..."))
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_ATMOS, do_flags = DO_REPAIR_CONSTRUCT) || clamp)
		return
	user.visible_message(
		SPAN_NOTICE("[user] unfastens [src]."),
		SPAN_NOTICE("You have unfastened [src]."),
		"You hear a ratchet.")

	new /obj/item/pipe(loc, src)
	for(var/obj/machinery/meter/meter in T)
		if(meter.target == src)
			meter.dismantle()
	qdel(src)

/obj/machinery/atmospherics/pipe/cap/sparker/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(signaler)
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		signaler.mholder = null
		signaler.dropInto(loc)
		user.visible_message(
			SPAN_WARNING("[user] disconnects [signaler] from [src]."),
			SPAN_WARNING("You disconnect [signaler] from [src].")
		)
		signaler = null
		update_icon()
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	disabled = !disabled
	user.visible_message(
		SPAN_WARNING("[user] has [disabled ? "disabled" : "reconnected wiring on"] [src]."),
		SPAN_WARNING("You [disabled ? "disable" : "fix"] the connection on [src].")
	)
	update_icon()

/obj/machinery/atmospherics/pipe/cap/sparker/use_tool(obj/item/W, mob/living/user, list/click_params)
	if (istype(W, /obj/item/device/assembly/signaler) && isnull(signaler))
		if (disabled)
			to_chat(user, SPAN_WARNING("[src] is disabled!"))
			return TRUE
		signaler = W
		if (signaler.secured)
			to_chat(user, SPAN_WARNING("[signaler] is secured!"))
			signaler = null
			return TRUE
		signaler.mholder = src
		user.unEquip(signaler)
		signaler.forceMove(src)
		user.visible_message(
			SPAN_NOTICE("[user] connects [signaler] to [src]."),
			SPAN_NOTICE("You connect [signaler] to [src].")
		)
		update_icon()
		return TRUE

	return ..()

/obj/machinery/atmospherics/pipe/cap/sparker/proc/process_activation()//the signaler calls this
	ignite()

/obj/machinery/atmospherics/pipe/cap/sparker/on_update_icon()
	..()
	if (signaler)
		AddOverlays(image('icons/atmos/pipe-sparker.dmi', "pipe-sparker-s"))
	if (disabled)
		AddOverlays(image('icons/atmos/pipe-sparker.dmi', "pipe-sparker-d"))
	update_underlays()

/obj/machinery/atmospherics/pipe/cap/sparker/update_underlays()
	if (..())
		underlays.Cut()
		var/turf/T = get_turf(src)
		if (!istype(T))
			return
		add_underlay(T, node, dir)

/obj/machinery/atmospherics/pipe/cap/sparker/set_color(new_color)
	return

/obj/machinery/atmospherics/pipe/cap/sparker/color_cache_name(obj/machinery/atmospherics/node)//returns to the original
	if (!istype(node))
		return null

	return node.pipe_color
