/obj/structure/curtain
	desc = "Yeap, that's curtains. You may uninstall them with a screwdriver."
	var/in_progress = FALSE //for (un)installing

/obj/structure/curtain/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/open/bed
	name = "bed curtain"
	color = "#854636"

/obj/structure/curtain/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(in_progress)
		return
	in_progress = TRUE
	user.visible_message(SPAN_NOTICE("[user] is uninstalling \the [src]."), SPAN_NOTICE("You are uninstalling \the [src]."))
	playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
	if(!do_after(user, 4 SECONDS, src))
		in_progress = FALSE
		return
	var/obj/item/curtain/C = new /obj/item/curtain(loc)
	C.color = color
	qdel(src)

/obj/item/curtain
	name = "rolled curtain"
	desc = "A rolled curtains. Looks like someone may install them with a screwdriver..."
	icon = 'packs/infinity/icons/obj/items.dmi'
	icon_state = "curtain_rolled"
	var/in_progress = FALSE
	force = 3 //just plastic
	w_class = ITEM_SIZE_HUGE //curtains, yeap

/obj/item/curtain/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(in_progress)
		return
	if(loc == user.loc)
		to_chat(user, "You cannot install [src] from your hands.")
		return
	in_progress = TRUE
	user.visible_message(SPAN_NOTICE("[user] is installing \the [src]."), SPAN_NOTICE("You are installing \the [src]."))
	playsound(src, 'sound/items/Screwdriver.ogg', 100, 1)
	if(!do_after(user, 4 SECONDS, src))
		in_progress = FALSE
		return
	var/obj/structure/curtain/C = new /obj/structure/curtain(loc)
	C.color = color
