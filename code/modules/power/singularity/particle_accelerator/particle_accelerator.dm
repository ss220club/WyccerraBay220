//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/*Composed of 7 parts
3 Particle emitters
emit_particle()

1 power box
the only part of this thing that uses power, can hack to mess with the pa/make it better.
Lies, only the control computer draws power.

1 fuel chamber
contains procs for mixing gas and whatever other fuel it uses
mix_gas()

1 gas holder WIP
acts like a tank valve on the ground that you wrench gas tanks onto
extract_gas()
return_gas()
attach_tank()
remove_tank()
get_available_mix()

1 End Cap

1 Control computer
interface for the pa, acts like a computer with an html menu for diff parts and a status report
all other parts contain only a ref to this
a /machine, tells the others to do work
contains ref for all parts
process()
check_build()

Setup map
  |EC|
CC|FC|
  |PB|
PE|PE|PE


Icon Addemdum
Icon system is much more robust, and the icons are all variable based.
Each part has a reference string, powered, strength, and contruction values.
Using this the update_icon() proc is simplified a bit (using for absolutely was problematic with naming),
so the icon_state comes out be:
"[reference][strength]", with a switch controlling construction_states and ensuring that it doesn't
power on while being contructed, and all these variables are set by the computer through it's scan list
Essential order of the icons:
Standard - [reference]
Wrenched - [reference]
Wired    - [reference]w
Closed   - [reference]c
Powered  - [reference]p[strength]
Strength being set by the computer and a null strength (Computer is powered off or inactive) returns a 'null', counting as empty
So, hopefully this is helpful if any more icons are to be added/changed/wondering what the hell is going on here

*/

/obj/structure/particle_accelerator
	name = "particle accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/machines/power/particle_accelerator2.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	obj_flags = OBJ_FLAG_ROTATABLE

	var/obj/machinery/particle_accelerator/control_box/master = null
	var/const/CONSTRUCT_STATE_UNANCHORED = 0
	var/const/CONSTRUCT_STATE_ANCHORED = 1
	var/const/CONSTRUCT_STATE_WIRED = 2
	var/const/CONSTRUCT_STATE_COMPLETE = 3
	var/construction_state = CONSTRUCT_STATE_UNANCHORED
	var/reference = null
	var/powered = 0
	var/strength = null
	var/desc_holder = null

/obj/structure/particle_accelerator/Destroy()
	construction_state = 0
	if(master)
		master.part_scan()
	. = ..()

/obj/structure/particle_accelerator/end_cap
	name = "alpha particle generation array"
	desc_holder = "This is where Alpha particles are generated from \[REDACTED\]"
	icon_state = "end_cap"
	reference = "end_cap"

/obj/structure/particle_accelerator/on_update_icon()
	..()
	return

/obj/structure/particle_accelerator/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(0)
			to_chat(user, "Looks like it's not attached to the flooring")
		if(1)
			to_chat(user, "It is missing some cables")
		if(2)
			to_chat(user, "The panel is open")
		if(3)
			if(powered)
				to_chat(user, desc_holder)
			else
				to_chat(user, "[src] is assembled")


/obj/structure/particle_accelerator/can_anchor(obj/item/tool, mob/user, silent)
	. = ..()
	if (!.)
		return
	if (construction_state > CONSTRUCT_STATE_ANCHORED)
		if (!silent)
			USE_FEEDBACK_FAILURE("[src] needs to be further dismantled before you can move it.")
		return FALSE


/obj/structure/particle_accelerator/post_anchor_change()
	construction_state = anchored ? CONSTRUCT_STATE_ANCHORED : CONSTRUCT_STATE_UNANCHORED
	update_state()
	update_icon()
	..()

/obj/structure/particle_accelerator/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(construction_state < CONSTRUCT_STATE_WIRED)
		balloon_alert(user, "нужно добавить проводку!")
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	if (construction_state == CONSTRUCT_STATE_WIRED)
		construction_state = CONSTRUCT_STATE_COMPLETE
	else
		construction_state = CONSTRUCT_STATE_WIRED
	update_icon()
	USE_FEEDBACK_NEW_PANEL_OPEN(construction_state != CONSTRUCT_STATE_COMPLETE)

/obj/structure/particle_accelerator/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if (construction_state < CONSTRUCT_STATE_WIRED)
		USE_FEEDBACK_FAILURE("[src] has no wiring to remove.")
		return
	if (construction_state > CONSTRUCT_STATE_WIRED)
		USE_FEEDBACK_FAILURE("[src]'s panel must be open before you can access the wiring.")
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	construction_state = CONSTRUCT_STATE_ANCHORED
	update_state()
	update_icon()
	user.visible_message(
		SPAN_NOTICE("[user] cuts [src]'s wiring with [tool]."),
		SPAN_NOTICE("You cut [src]'s wiring with [tool].")
	)

/obj/structure/particle_accelerator/use_tool(obj/item/tool, mob/user, list/click_params)
	// Cable Coil - Add wiring
	if (isCoil(tool))
		if (construction_state < CONSTRUCT_STATE_ANCHORED)
			USE_FEEDBACK_FAILURE("[src] needs to be anchored before you can wire it.")
			return TRUE
		if (construction_state > CONSTRUCT_STATE_ANCHORED)
			USE_FEEDBACK_FAILURE("[src] is already wired.")
			return TRUE
		var/obj/item/stack/cable_coil/cable = tool
		if (!cable.use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 1, "to wire [src].")
			return TRUE
		construction_state = CONSTRUCT_STATE_WIRED
		update_state()
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] wires [src] with [tool]."),
			SPAN_NOTICE("You wire [src] with [tool].")
		)
		return TRUE
	return ..()


/obj/structure/particle_accelerator/Move()
	..()
	if(master && master.active)
		master.toggle_power()
		investigate_log("was moved whilst active; it [SPAN_COLOR("red", "powered down")].","singulo")

/obj/structure/particle_accelerator/ex_act(severity)
	switch(severity)
		if(EX_ACT_DEVASTATING)
			qdel(src)
			return
		if(EX_ACT_HEAVY)
			if (prob(50))
				qdel(src)
				return
		if(EX_ACT_LIGHT)
			if (prob(25))
				qdel(src)
				return
		else
	return

/obj/structure/particle_accelerator/on_update_icon()
	switch(construction_state)
		if(0,1)
			icon_state="[reference]"
		if(2)
			icon_state="[reference]w"
		if(3)
			if(powered)
				icon_state="[reference]p[strength]"
			else
				icon_state="[reference]c"
	return

/obj/structure/particle_accelerator/proc/update_state()
	if(master)
		master.update_state()
		return 0


/obj/structure/particle_accelerator/proc/report_ready(obj/O)
	if(O && (O == master))
		if(construction_state >= 3)
			return 1
	return 0


/obj/structure/particle_accelerator/proc/report_master()
	if(master)
		return master
	return 0


/obj/structure/particle_accelerator/proc/connect_master(obj/O)
	if(O && istype(O,/obj/machinery/particle_accelerator/control_box))
		if(O.dir == src.dir)
			master = O
			return 1
	return 0


/obj/machinery/particle_accelerator
	name = "particle accelerator"
	desc = "Part of a Particle Accelerator."
	icon = 'icons/obj/machines/power/particle_accelerator2.dmi'
	icon_state = "none"
	anchored = FALSE
	density = TRUE
	use_power = POWER_USE_OFF
	idle_power_usage = 0
	active_power_usage = 0
	var/construction_state = 0
	var/active = 0
	var/reference = null
	var/powered = null
	var/strength = 0
	var/desc_holder = null

/obj/machinery/particle_accelerator/on_update_icon()
	return

/obj/machinery/particle_accelerator/examine(mob/user)
	. = ..()
	switch(construction_state)
		if(0)
			to_chat(user, "Looks like it's not attached to the flooring")
		if(1)
			to_chat(user, "It is missing some cables")
		if(2)
			to_chat(user, "The panel is open")
		if(3)
			if(powered)
				to_chat(user, desc_holder)
			else
				to_chat(user, "[src] is assembled")

/obj/machinery/particle_accelerator/ex_act(severity)
	switch(severity)
		if(EX_ACT_DEVASTATING)
			qdel(src)
			return
		if(EX_ACT_HEAVY)
			if (prob(50))
				qdel(src)
				return
		if(EX_ACT_LIGHT)
			if (prob(25))
				qdel(src)
				return
		else
	return


/obj/machinery/particle_accelerator/proc/update_state()
	return 0

/obj/machinery/particle_accelerator/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	switch(construct_state)
		if(2)
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			USE_FEEDBACK_NEW_PANEL_OPEN(FALSE)
			construct_state = 3
		if(3)
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			USE_FEEDBACK_NEW_PANEL_OPEN(TRUE)
			construct_state = 2
			active = FALSE
	check_step()

/obj/machinery/particle_accelerator/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	switch(construct_state)
		if(0)
			if(!tool.use_as_tool(src, user, volume = 75, do_flags = DO_REPAIR_CONSTRUCT))
				return
			anchored = TRUE
			user.visible_message("[user.name] secures the [src.name] to the floor.", \
				"You secure the external bolts.")
			construct_state = 1
		if(1)
			if(!tool.use_as_tool(src, user, volume = 75, do_flags = DO_REPAIR_CONSTRUCT))
				return
			anchored = FALSE
			user.visible_message("[user.name] detaches the [src.name] from the floor.", \
				"You remove the external bolts.")
			construct_state = 0
	check_step()

/obj/machinery/particle_accelerator/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(construct_state != 2)
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	user.visible_message("[user.name] removes some wires from the [src.name].", \
		"You remove some wires.")
	construct_state = 1
	check_step()

/obj/machinery/particle_accelerator/use_tool(obj/item/I, mob/living/user, list/click_params)
	if(isCoil(I) && construction_state == 1)
		var/obj/item/stack/cable_coil/A = I
		if(A.use(1))
			user.visible_message("[user.name] adds wires to the [src.name].", \
				"You add some wires.")
			construct_state = 2
			check_step()
		return TRUE
	. = ..()

/obj/machinery/particle_accelerator/proc/check_step()
	if(construction_state < 3) //Was taken apart, update state
		update_state()
		if(use_power)
			update_use_power(POWER_USE_OFF)
	else
		update_use_power(POWER_USE_IDLE)
	update_icon()
