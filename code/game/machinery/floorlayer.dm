/obj/machinery/floorlayer
	name = "automatic floor layer"
	icon = 'icons/obj/machines/pipe_dispenser.dmi'
	icon_state = "pipe_d"
	density = TRUE
	var/turf/old_turf
	var/on = 0
	var/obj/item/stack/tile/current_tile
	var/list/mode = list("dismantle"=0,"laying"=0,"collect"=0)

/obj/machinery/floorlayer/Initialize()
	. = ..()
	var/obj/item/stack/tile/floor/new_tile = new(get_turf(loc))
	take_tile(new_tile)

/obj/machinery/floorlayer/Move(new_turf,M_Dir)
	. = ..()
	if(on)
		if(mode["dismantle"])
			dismantle_floor(old_turf)
		if(mode["laying"])
			lay_floor(old_turf)
		if(mode["collect"])
			collect_tiles(old_turf)
	old_turf = new_turf

/obj/machinery/floorlayer/physical_attack_hand(mob/user)
	on=!on
	user.visible_message(
		SPAN_NOTICE("[user] has [!on?"de":""]activated [src]."),
		SPAN_NOTICE("You [!on?"de":""]activate [src].")
	)
	return TRUE

/obj/machinery/floorlayer/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	var/list/tiles = get_tiles()
	if(!length(tiles))
		to_chat(user, SPAN_NOTICE("[src] is empty."))
		return
	var/obj/item/stack/tile/tile_to_remove = input("Choose remove tile type.", "Tiles") as null|anything in tiles
	if(!istype(tile_to_remove))
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	tile_to_remove.forceMove(get_turf(loc))
	current_tile = null
	to_chat(user, SPAN_NOTICE("You remove the [tile_to_remove] from [src]."))

/obj/machinery/floorlayer/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	var/list/tiles = get_tiles()
	if(!length(tiles))
		to_chat(user, SPAN_NOTICE("[src] is empty."))
		return
	var/obj/item/stack/tile/new_tile = input("Choose tile type.", "Tiles") as null|anything in tiles
	if(!istype(new_tile))
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	current_tile = new_tile

/obj/machinery/floorlayer/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	var/m = input("Choose work mode", "Mode") as null|anything in mode
	if(!m)
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	mode[m] = !mode[m]
	var/O = mode[m]
	user.visible_message(
		SPAN_NOTICE("[user] has set [src] [m] mode [!O?"off":"on"]."),
		SPAN_NOTICE("You set [src] [m] mode [!O?"off":"on"].")
	)

/obj/machinery/floorlayer/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(istype(W, /obj/item/stack/tile))
		if(!user.unEquip(W, get_turf(loc)))
			return TRUE
		to_chat(user, SPAN_NOTICE("[W] successfully loaded."))
		take_tile(W)
		return TRUE
	return ..()

/obj/machinery/floorlayer/examine(mob/user)
	. = ..()
	var/dismantle = mode["dismantle"]
	var/laying = mode["laying"]
	var/collect = mode["collect"]
	var/message = SPAN_NOTICE("[src] [!current_tile?"don't ":""]has [!current_tile?"":"[current_tile.get_amount()] [current_tile] "]tile\s, dismantle is [dismantle?"on":"off"], laying is [laying?"on":"off"], collect is [collect?"on":"off"].")
	. += message

/obj/machinery/floorlayer/proc/reset()
	on = 0

/obj/machinery/floorlayer/proc/get_tiles()
	var/list/tiles = list()
	for(var/obj/item/stack/tile/tile in contents)
		tiles += tile
	return tiles

/obj/machinery/floorlayer/proc/dismantle_floor(turf/new_turf)
	if(istype(new_turf, /turf/simulated/floor))
		var/turf/simulated/floor/to_dismantle = new_turf
		if(!to_dismantle.is_plating())
			to_dismantle.make_plating(!(to_dismantle.broken || to_dismantle.burnt))

/obj/machinery/floorlayer/proc/lay_floor(turf/w_turf)
	if(!current_tile || !current_tile.loc)
		for(var/obj/item/stack/tile/tile in contents)
			current_tile = tile
			break
	if(!current_tile)
		return
	w_turf.use_tool(current_tile, src)

/obj/machinery/floorlayer/proc/take_tile(obj/item/stack/tile/tile)
	for(var/obj/item/stack/tile/tile1 in contents)
		if(tile.transfer_to(tile1))
			return
	tile.forceMove(src)

/obj/machinery/floorlayer/proc/collect_tiles(turf/w_turf)
	for(var/obj/item/stack/tile/tile in w_turf)
		take_tile(tile)
