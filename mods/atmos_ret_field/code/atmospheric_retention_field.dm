// Activate all retention fields!
/area/proc/arfgs_activate()
	if(!arfgs_active)
		arfgs_active = TRUE
		if(!all_arfgs)
			return
		for(var/obj/machinery/atmospheric_field_generator/E in all_arfgs)
			E.generate_field() //don't need to check powered state like doors, the arfgs handles it on its end
			E.wasactive = TRUE

// Deactivate retention fields!
/area/proc/arfgs_deactivate()
	if(arfgs_active)
		arfgs_active = FALSE
		if(!all_arfgs)
			return
		for(var/obj/machinery/atmospheric_field_generator/E in all_arfgs)
			E.disable_field()
			E.wasactive = FALSE


/obj/machinery/atmospheric_field_generator
	name = "atmospheric retention field generator"
	desc = "A floor-mounted piece of equipment that generates an atmosphere-retaining energy field when powered and activated. Linked to environmental alarm systems and will automatically activate when hazardous conditions are detected.<br><br>Note: prolonged immersion in active atmospheric retention fields may have negative long-term health consequences."
	icon = 'mods/atmos_ret_field/icons/atm_fieldgen.dmi'
	icon_state = "arfg_off"
	anchored = TRUE
	opacity = FALSE
	density = FALSE
	power_channel = ENVIRON	//so they shut off last
	use_power = POWER_USE_IDLE
	idle_power_usage = 10
	active_power_usage = 2500
	var/ispowered = TRUE
	var/isactive = FALSE
	var/wasactive = FALSE		//controls automatic reboot after power-loss
	var/alwaysactive = FALSE	//for a special subtype

	//how long it takes us to reboot if we're shut down by an EMP
	var/reboot_delay_min = 50
	var/reboot_delay_max = 75

	var/hatch_open = FALSE
	var/wires_intact = TRUE
	var/list/areas_added
	var/field_type = /obj/structure/atmospheric_retention_field

/obj/machinery/atmospheric_field_generator/impassable
	desc = "An older model of ARF-G that generates an impassable retention field. Works just as well as the modern variety, but is slightly more energy-efficient.<br><br>Note: prolonged immersion in active atmospheric retention fields may have negative long-term health consequences."
	active_power_usage = 2000
	field_type = /obj/structure/atmospheric_retention_field/impassable

/obj/machinery/atmospheric_field_generator/perma
	name = "static atmospheric retention field generator"
	desc = "A floor-mounted piece of equipment that generates an atmosphere-retaining energy field when powered and activated. This model is designed to always be active, though the field will still drop from loss of power or electromagnetic interference.<br><br>Note: prolonged immersion in active atmospheric retention fields may have negative long-term health consequences."
	alwaysactive = TRUE
	active_power_usage = 2000

/obj/machinery/atmospheric_field_generator/perma/impassable
	active_power_usage = 1500
	field_type = /obj/structure/atmospheric_retention_field/impassable

/obj/machinery/atmospheric_field_generator/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(isactive)
		USE_FEEDBACK_FAILURE("You can't open the ARF-G whilst it's running!")
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	to_chat(user, SPAN_NOTICE("You [hatch_open? "close" : "open"] [src]'s access hatch."))
	hatch_open = !hatch_open
	update_icon()
	if(alwaysactive && wires_intact)
		generate_field()

/obj/machinery/atmospheric_field_generator/multitool_act(mob/living/user, obj/item/tool)
	if(!hatch_open)
		return
	. = ITEM_INTERACT_SUCCESS
	to_chat(user, SPAN_NOTICE("You toggle [src]'s activation behavior to [alwaysactive? "emergency" : "always-on"]."))
	alwaysactive = !alwaysactive
	update_icon()

/obj/machinery/atmospheric_field_generator/wirecutter_act(mob/living/user, obj/item/tool)
	if(!hatch_open)
		return
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	to_chat(user, SPAN_WARNING("You [wires_intact? "cut" : "mend"] [src]'s wires!"))
	wires_intact = !wires_intact
	update_icon()

/obj/machinery/atmospheric_field_generator/welder_act(mob/living/user, obj/item/tool)
	if(!hatch_open)
		return
	. = ITEM_INTERACT_SUCCESS
	if(!tool.tool_start_check(user, 5))
		return
	USE_FEEDBACK_DECONSTRUCT_START
	if(!tool.use_as_tool(src, user, 2 SECONDS, 5, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	user.visible_message("[user] disassembles [src].", "You disassemble [src].")
	qdel(src)

/obj/machinery/atmospheric_field_generator/perma/Initialize()
	. = ..()
	generate_field()

/obj/machinery/atmospheric_field_generator/on_update_icon()
	if(MACHINE_IS_BROKEN(src))
		icon_state = "arfg_broken"
	else if(hatch_open && wires_intact)
		icon_state = "arfg_open_wires"
	else if(hatch_open && !wires_intact)
		icon_state = "arfg_open_wirescut"
	else if(isactive)
		icon_state = "arfg_on"
	else
		icon_state = "arfg_off"

/obj/machinery/atmospheric_field_generator/power_change()
	var/oldstat
	..()
	if(!(stat & MACHINE_STAT_NOPOWER))
		ispowered = 1
		update_icon()
		if(alwaysactive || wasactive)	//reboot our field if we were on or are supposed to be always-on
			generate_field()
	if(stat != oldstat && isactive && (stat & MACHINE_STAT_NOPOWER))
		ispowered = 0
		disable_field()
		update_icon()

/obj/machinery/atmospheric_field_generator/emp_act()
	. = ..()
	disable_field() //shutting dowwwwwwn
	if(alwaysactive || wasactive) //reboot after a short delay if we were online before
		spawn(rand(reboot_delay_min,reboot_delay_max))
			generate_field()

/obj/machinery/atmospheric_field_generator/ex_act(severity)
	switch(severity)
		if(1)
			disable_field()
			qdel(src)
			return
		if(2)
			set_broken(TRUE)
			update_icon()
			src.visible_message("The ARF-G cracks and shatters!","You hear an uncomfortable metallic crunch.")
			disable_field()
		if(3)
			emp_act()
	return

/obj/machinery/atmospheric_field_generator/proc/generate_field()
	if(!ispowered || hatch_open || !wires_intact || isactive) //if it's not powered, the hatch is open, the wires are busted, or it's already on, don't do anything
		return
	else
		isactive = 1
		icon_state = "arfg_on"
		new field_type (src.loc)
		src.visible_message("<span class='warning'>The ARF-G crackles to life!</span>","<span class='warning'>You hear an ARF-G coming online!</span>")
		update_use_power(POWER_USE_ACTIVE)
	return

/obj/machinery/atmospheric_field_generator/proc/disable_field()
	if(isactive)
		icon_state = "arfg_off"
		for(var/obj/structure/atmospheric_retention_field/F in loc)
			qdel(F)
		src.visible_message("The ARF-G shuts down with a low hum.","You hear an ARF-G powering down.")
		update_use_power(POWER_USE_IDLE)
		isactive = 0
	return

/obj/machinery/atmospheric_field_generator/Initialize()
	. = ..()
	//Delete ourselves if we find extra mapped in arfgs
	for(var/obj/machinery/atmospheric_field_generator/F in loc)
		if(F != src)
			log_debug("Duplicate ARFGS at [x],[y],[z]")
			return INITIALIZE_HINT_QDEL

	var/area/A = get_area(src)
	ASSERT(istype(A))

	LAZYADD(A.all_arfgs, src)
	areas_added = list(A)

	for(var/direction in GLOB.cardinal)
		A = get_area(get_step(src,direction))
		if(istype(A) && !(A in areas_added))
			LAZYADD(A.all_arfgs, src)
			areas_added += A

/obj/structure/atmospheric_retention_field
	name = "atmospheric retention field"
	desc = "A shimmering forcefield that keeps the good air inside and the bad air outside. This field has been modulated so that it doesn't impede movement or projectiles.<br><br>Note: prolonged immersion in active atmospheric retention fields may have negative long-term health consequences."
	icon = 'mods/atmos_ret_field/icons/atm_fieldgen.dmi'
	icon_state = "arfg_field"
	anchored = TRUE
	density = FALSE
	opacity = 0
	layer = BASE_HUMAN_LAYER
	atmos_canpass = CANPASS_NEVER
	var/basestate = "arfg_field"

	light_range = 13
	light_power = 2
	light_color = "#ffffff"

/obj/structure/atmospheric_retention_field/on_update_icon()
	ClearOverlays()
	var/list/dirs = list()
	for(var/obj/structure/atmospheric_retention_field/F in orange(src,1))
		dirs += get_dir(src, F)

	var/list/connections = dirs_to_corner_states(dirs)

	icon_state = ""
	for(var/i = 1 to 4)
		var/image/I = image(icon, "[basestate][connections[i]]", dir = SHIFTL(1, i-1))
		AddOverlays(I)

	return

/obj/structure/atmospheric_retention_field/Initialize()
	. = ..()
	update_nearby_tiles() //Force ZAS update
	update_connections(1)
	update_icon()

/obj/structure/atmospheric_retention_field/Destroy()
	for(var/obj/structure/atmospheric_retention_field/W in orange(1, src.loc))
		W.update_connections(1)
	update_nearby_tiles() //Force ZAS update
	. = ..()

/obj/structure/atmospheric_retention_field/attack_hand(mob/user as mob)
	if(density)
		visible_message("You touch the retention field, and it crackles faintly. Tingly!")
	else
		visible_message("You try to touch the retention field, but pass through it like it isn't even there.")

/obj/structure/atmospheric_retention_field/ex_act()
	return

/obj/structure/atmospheric_retention_field/impassable
	desc = "A shimmering forcefield that keeps the good air inside and the bad air outside. It seems fairly solid, almost like it's made out of some kind of hardened light.<br><br>Note: prolonged immersion in active atmospheric retention fields may have negative long-term health consequences."
	icon = 'mods/atmos_ret_field/icons/atm_fieldgen.dmi'
	icon_state = "arfg_field"
	density = TRUE
