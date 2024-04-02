/obj/item/flora/pottedplantsmall
	name = "small potted plant"
	desc = "This is a pot of assorted small flora. Some look familiar."
	icon = 'icons/obj/flora/plants.dmi'
	icon_state = "plant-15"
	item_state = "plant-15"
	w_class = ITEM_SIZE_LARGE

/obj/item/flora/pottedplantsmall/leaf
	name = "fancy leafy potted desk plant"
	desc = "A tiny waxy leafed plant specimen."
	icon_state = "plant-29"
	item_state = "plant-29"

/obj/item/flora/pottedplantsmall/fern
	name = "fancy ferny potted plant"
	desc = "This leafy desk fern could do with a trim."
	icon_state = "plant-27"
	item_state = "plant-27"
	var/trimmed = FALSE

/obj/item/flora/pottedplantsmall/fern/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	visible_message(SPAN_NOTICE("[user] starts trimming the [src] with [tool]."))
	if(!tool.use_as_tool(src, user, 6 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_PUBLIC_UNIQUE))
		return
	to_chat(user, SPAN_NOTICE("You trim [src] with [tool]. You probably should've used a pair of scissors."))
	trimmed = TRUE
	addtimer(CALLBACK(src, PROC_REF(grow)), 90 MINUTES, TIMER_UNIQUE|TIMER_OVERRIDE)
	update_icon()

/obj/item/flora/pottedplantsmall/fern/on_update_icon()
	. = ..()
	if (trimmed)
		name = "fancy trimmed ferny potted plant"
		desc = "This leafy desk fern seems to have been trimmed too much."
		icon_state = "plant-30"
		item_state = "plant-30"
	else
		name = "fancy ferny potted plant"
		desc = "This leafy desk fern could do with a trim."
		icon_state = "plant-27"
		item_state = "plant-27"

/obj/item/flora/pottedplantsmall/fern/proc/grow()
	trimmed = FALSE
	update_icon()
