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
	user.visible_message(SPAN_NOTICE("[user] is uninstalling [src]."), SPAN_NOTICE("You are uninstalling [src]."))
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	var/obj/item/curtain/C = new /obj/item/curtain(loc)
	C.color = color
	qdel(src)

/obj/item/curtain
	name = "rolled curtain"
	desc = "A rolled curtains. Looks like someone may install them with a screwdriver..."
	icon = 'packs/infinity/icons/obj/items.dmi'
	icon_state = "curtain_rolled"
	force = 3 //just plastic
	w_class = ITEM_SIZE_HUGE //curtains, yeap

/obj/item/curtain/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(loc == user.loc)
		to_chat(user, "You cannot install [src] from your hands.")
		return
	user.visible_message(SPAN_NOTICE("[user] is installing [src]."), SPAN_NOTICE("You are installing [src]."))
	if(!tool.use_as_tool(src, user, 4 SECONDS, volume = 50, skill_path = SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	var/obj/structure/curtain/C = new /obj/structure/curtain(loc)
	C.color = color
