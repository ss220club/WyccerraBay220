/obj/item/storage/fancy/matches/matchbox
	name = "matchbox"
	desc = "A small box of 'Space-Proof' premium matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbox"
	open_sound = 'sound/effects/storage/box.ogg'
	max_storage_space = 10
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_BELT
	contents_allowed = list(/obj/item/flame/match)
	key_type = list(/obj/item/flame/match)
	startswith = list(/obj/item/flame/match = 10)
	var/sprite_key_type_count = 3

/obj/item/storage/fancy/matches/matchbook
	name = "matchbook"
	desc = "A tiny packet of 'Space-Proof' premium matches."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "matchbook"
	open_sound = 'sound/effects/pageturn2.ogg'
	max_storage_space = 3
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS
	contents_allowed = list(/obj/item/flame/match)
	key_type = list(/obj/item/flame/match)
	startswith = list(/obj/item/flame/match = 3)


/obj/item/storage/fancy/matches/use_tool(obj/item/W, mob/living/user, list/click_params)
	if(!opened && istype(W, /obj/item/flame/match))
		var/obj/item/flame/match/match_to_light = W
		if(!match_to_light.lit && !match_to_light.burnt)
			match_to_light.lit = TRUE
			match_to_light.damtype = INJURY_TYPE_BURN
			match_to_light.icon_state = "match_lit"
			START_PROCESSING(SSobj, match_to_light)
			playsound(loc, 'sound/items/match.ogg', 60, 1, -4)
			user.visible_message(SPAN_NOTICE("[user] strikes the match on \the [src]."))
			match_to_light.update_icon()
			return TRUE

	return ..()

///Exclusive to larger matchboxes; as cigarette boxes and matchbooks have one sprite per removed item while these do not.

/obj/item/storage/fancy/matches/matchbox/UpdateTypeCounts()
	. = ..()
	switch(key_type_count)
		if(0)
			sprite_key_type_count = 0
		if(1 to 3)
			sprite_key_type_count = 1
		if(4 to 7)
			sprite_key_type_count = 2
		if(8 to 10)
			sprite_key_type_count = 3

/obj/item/storage/fancy/matches/matchbox/on_update_icon()
	icon_state = "[initial(icon_state)][opened ? sprite_key_type_count : ""]"
