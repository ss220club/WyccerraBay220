/obj/machinery/power/debug_items
	icon = 'icons/obj/machines/power/solar_panels.dmi'
	icon_state = "tracker"
	anchored = TRUE
	density = TRUE
	var/show_extended_information = 1	// Set to 0 to disable extra information on examining (for example, when used on admin events)

/obj/machinery/power/debug_items/examine(mob/user)
	. = ..()
	if(show_extended_information)
		show_info(user)

/obj/machinery/power/debug_items/proc/show_info(mob/user)
	if(!powernet)
		. += SPAN_NOTICE("This device is not connected to a powernet")
		return

	. += SPAN_NOTICE("Connected to powernet: [powernet]")
	. += SPAN_NOTICE("Available power: [num2text(powernet.avail, 20)] W")
	. += SPAN_NOTICE("Load: [num2text(powernet.viewload, 20)] W")
	. += SPAN_NOTICE("Has alert: [powernet.problem ? "YES" : "NO"]")
	. += SPAN_NOTICE("Cables: [length(powernet.cables)]")
	. += SPAN_NOTICE("Nodes: [length(powernet.nodes)]")


// An infinite power generator. Adds energy to connected cable.
/obj/machinery/power/debug_items/infinite_generator
	name = "fractal energy reactor"
	desc = "An experimental power generator."
	var/power_generation_rate = 1000000

/obj/machinery/power/debug_items/infinite_generator/Process()
	add_avail(power_generation_rate)

/obj/machinery/power/debug_items/infinite_generator/show_info(mob/user)
	..()
	to_chat(user, "Generator is providing [num2text(power_generation_rate, 20)] W")


// A cable powersink, without the explosion/network alarms normal powersink causes.
/obj/machinery/power/debug_items/infinite_cable_powersink
	name = "null point core"
	desc = "An experimental device that disperses energy, used for grid testing purposes."
	var/power_usage_rate = 0
	var/last_used = 0

/obj/machinery/power/debug_items/infinite_cable_powersink/Process()
	last_used = draw_power(power_usage_rate)

/obj/machinery/power/debug_items/infinite_cable_powersink/show_info(mob/user)
	..()
	to_chat(user, "Power sink is demanding [num2text(power_usage_rate, 20)] W")
	to_chat(user, "[num2text(last_used, 20)] W was actually used last tick")


/obj/machinery/power/debug_items/infinite_apc_powersink
	name = "\improper APC dummy load"
	desc = "A dummy load that connects to an APC, used for load testing purposes."
	use_power = POWER_USE_ACTIVE
	active_power_usage = 0

/obj/machinery/power/debug_items/infinite_apc_powersink/show_info(mob/user)
	..()
	to_chat(user, "Dummy load is using [num2text(active_power_usage, 20)] W")
	to_chat(user, "Powered: [powered() ? "YES" : "NO"]")
