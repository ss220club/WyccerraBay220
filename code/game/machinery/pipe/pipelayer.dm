/obj/machinery/pipelayer

	name = "automatic pipe layer"
	icon = 'icons/obj/machines/pipe_dispenser.dmi'
	icon_state = "pipe_d"
	density = TRUE
	var/turf/old_turf
	var/old_dir
	var/on = 0
	var/a_dis = 0
	var/P_type = 0
	var/P_type_t = ""
	var/max_metal = 50
	var/metal = 10
	var/obj/item/wrench/W
	var/list/Pipes = list("regular pipes"=0,"scrubbers pipes"=31,"supply pipes"=29,"heat exchange pipes"=2, "fuel pipes"=45)

/obj/machinery/pipelayer/New()
	W = new(src)
	..()

/obj/machinery/pipelayer/Move(new_turf,M_Dir)
	..()

	if(on && a_dis)
		dismantleFloor(old_turf)
	layPipe(old_turf,M_Dir,old_dir)

	old_turf = new_turf
	old_dir = turn(M_Dir,180)

/obj/machinery/pipelayer/interface_interact(mob/user)
	if(!metal&&!on)
		to_chat(user, SPAN_WARNING("[src] doesn't work without metal."))
		return TRUE
	on=!on
	user.visible_message(
		SPAN_NOTICE("[user] has [!on?"de":""]activated [src]."),
		SPAN_NOTICE("You [!on?"de":""]activate [src].")
	)
	return TRUE

/obj/machinery/pipelayer/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	a_dis=!a_dis
	user.visible_message(
		SPAN_NOTICE("[user] has [!a_dis?"de":""]activated auto-dismantling."),
		SPAN_NOTICE("You [!a_dis?"de":""]activate auto-dismantling.")
	)

/obj/machinery/pipelayer/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!metal)
		to_chat(user, "[src] is empty.")
		return
	var/m = round(input(usr,"Please specify the amount of metal to remove","Remove metal",min(round(metal),50)) as num, 1)
	m = min(m, 50)
	m = min(m, round(metal))
	m = round(m)
	if(m)
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		use_metal(m)
		var/obj/item/stack/material/steel/MM = new (get_turf(src))
		MM.amount = m
		user.visible_message(SPAN_NOTICE("[user] removes [m] sheet\s of metal from the [src]."), SPAN_NOTICE("You remove [m] sheet\s of metal from [src]"))

/obj/machinery/pipelayer/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	P_type_t = input("Choose pipe type", "Pipe type") as null|anything in Pipes
	if(!P_type_t)
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	P_type = Pipes[P_type_t]
	user.visible_message(SPAN_NOTICE("[user] has set [src] to manufacture [P_type_t]."), SPAN_NOTICE("You set [src] to manufacture [P_type_t]."))

/obj/machinery/pipelayer/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/stack/material) && W.get_material_name() == MATERIAL_STEEL)
		var/result = load_metal(W)
		if(isnull(result))
			to_chat(user, SPAN_WARNING("Unable to load [W] - no metal found."))
		else if(!result)
			to_chat(user, SPAN_NOTICE("[src] is full."))
		else
			user.visible_message(SPAN_NOTICE("[user] has loaded metal into [src]."), SPAN_NOTICE("You load metal into [src]"))
		return TRUE

	return ..()

/obj/machinery/pipelayer/examine(mob/user)
	. = ..()
	to_chat(user, "[src] has [metal] sheet\s, is set to produce [P_type_t], and auto-dismantling is [!a_dis?"de":""]activated.")

/obj/machinery/pipelayer/proc/reset()
	on=0
	return

/obj/machinery/pipelayer/proc/load_metal(obj/item/stack/MM)
	if(istype(MM) && MM.get_amount())
		var/cur_amount = metal
		var/to_load = max(max_metal - round(cur_amount),0)
		if(to_load)
			to_load = min(MM.get_amount(), to_load)
			metal += to_load
			MM.use(to_load)
			return to_load
		else
			return 0
	return

/obj/machinery/pipelayer/proc/use_metal(amount)
	if(!metal || metal<amount)
		visible_message("[src] deactivates as its metal source depletes.")
		return
	metal-=amount
	return 1

/obj/machinery/pipelayer/proc/dismantleFloor(turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!T.is_plating())
			T.make_plating(!(T.broken || T.burnt))
	return new_turf.is_plating()

/obj/machinery/pipelayer/proc/layPipe(turf/w_turf,M_Dir,old_dir)
	if(!on || !(M_Dir in list(1, 2, 4, 8)) || M_Dir==old_dir)
		return reset()
	if(!use_metal(0.25))
		return reset()
	var/fdirn = turn(M_Dir,180)
	var/p_dir

	if (fdirn!=old_dir)
		p_dir=old_dir+M_Dir
	else
		p_dir=M_Dir

	var/obj/item/pipe/P = new(w_turf)
	P.set_dir(p_dir)
	W.resolve_attackby(P, src) // TODO: does this even work?

	return 1
