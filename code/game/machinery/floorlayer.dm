/obj/machinery/floorlayer

	name = "automatic floor layer"
	icon = 'icons/obj/machines/pipe_dispenser.dmi'
	icon_state = "pipe_d"
	density = TRUE
	var/turf/old_turf
	var/on = 0
	var/obj/item/stack/tile/T
	var/list/mode = list("dismantle"=0,"laying"=0,"collect"=0)

/obj/machinery/floorlayer/New()
	T = new/obj/item/stack/tile/floor(src)
	..()

/obj/machinery/floorlayer/Move(new_turf,M_Dir)
	..()

	if(on)
		if(mode["dismantle"])
			dismantleFloor(old_turf)

		if(mode["laying"])
			layFloor(old_turf)

		if(mode["collect"])
			CollectTiles(old_turf)


	old_turf = new_turf

/obj/machinery/floorlayer/physical_attack_hand(mob/user)
	on=!on
	user.visible_message(
		SPAN_NOTICE("\The [user] has [!on?"de":""]activated \the [src]."),
		SPAN_NOTICE("You [!on?"de":""]activate \the [src].")
	)
	return TRUE

/obj/machinery/floorlayer/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!length(contents))
		to_chat(user, SPAN_NOTICE("\The [src] is empty."))
	else
		var/obj/item/stack/tile/E = input("Choose remove tile type.", "Tiles") as null|anything in contents
		if(E)
			to_chat(user, SPAN_NOTICE("You remove the [E] from /the [src]."))
			E.dropInto(loc)
			T = null

/obj/machinery/floorlayer/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	T = input("Choose tile type.", "Tiles") as null|anything in contents

/obj/machinery/floorlayer/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	var/m = input("Choose work mode", "Mode") as null|anything in mode
	mode[m] = !mode[m]
	var/O = mode[m]
	user.visible_message(
		SPAN_NOTICE("\The [user] has set \the [src] [m] mode [!O?"off":"on"]."),
		SPAN_NOTICE("You set \the [src] [m] mode [!O?"off":"on"].")
	)

/obj/machinery/floorlayer/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/stack/tile))
		if(!user.unEquip(W, T))
			return TRUE
		to_chat(user, SPAN_NOTICE("\The [W] successfully loaded."))
		TakeTile(T)
		return TRUE
	return ..()

/obj/machinery/floorlayer/examine(mob/user)
	. = ..()
	var/dismantle = mode["dismantle"]
	var/laying = mode["laying"]
	var/collect = mode["collect"]
	var/message = SPAN_NOTICE("\The [src] [!T?"don't ":""]has [!T?"":"[T.get_amount()] [T] "]tile\s, dismantle is [dismantle?"on":"off"], laying is [laying?"on":"off"], collect is [collect?"on":"off"].")
	to_chat(user, message)

/obj/machinery/floorlayer/proc/reset()
	on = 0

/obj/machinery/floorlayer/proc/dismantleFloor(turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/T = new_turf
		if(!T.is_plating())
			T.make_plating(!(T.broken || T.burnt))
	return new_turf.is_plating()

/obj/machinery/floorlayer/proc/TakeNewStack()
	for(var/obj/item/stack/tile/tile in contents)
		T = tile
		return 1
	return 0

/obj/machinery/floorlayer/proc/SortStacks()
	for(var/obj/item/stack/tile/tile1 in contents)
		for(var/obj/item/stack/tile/tile2 in contents)
			tile2.transfer_to(tile1)

/obj/machinery/floorlayer/proc/layFloor(turf/w_turf)
	if(!T)
		if(!TakeNewStack())
			return 0
	w_turf.use_tool(T , src)
	return 1

/obj/machinery/floorlayer/proc/TakeTile(obj/item/stack/tile/tile)
	if(!T)	T = tile
	tile.forceMove(src)

	SortStacks()

/obj/machinery/floorlayer/proc/CollectTiles(turf/w_turf)
	for(var/obj/item/stack/tile/tile in w_turf)
		TakeTile(tile)
