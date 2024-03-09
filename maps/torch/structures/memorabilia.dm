//For event mementos or things that largely lore specific and have limited use
/obj/structure/decorative
	name = "decorations"
	anchored = TRUE
	density = FALSE
	layer = ABOVE_HUMAN_LAYER

/obj/structure/decorative/ed209
	name = "salvaged ED-209 Security Robot"
	desc = "A security robot.  He looks less than thrilled. This one has had multiple parts stripped off and its internal systems are exposed. You can make out a charred stencil reading 'SFV Jonah'."
	icon = 'icons/mob/bot/ED209.dmi'
	icon_state = "ed2090-salvage"
	var/salvaged = FALSE
	obj_flags = OBJ_FLAG_ANCHORABLE
	var/list/loot = list(/obj/item/cell/super,/obj/item/stock_parts/manipulator/nano, /obj/item/stock_parts/micro_laser/high, /obj/item/robot_parts/robot_component/actuator)

/obj/structure/decorative/ed209/Initialize()
	. = ..()
	update_icon()

/obj/structure/decorative/ed209/examine(mob/user)
	. = ..()
	if(anchored)
		to_chat(user, "Magnetic chains hold it in place. Somebody isn't taking any risks with this one.")

/obj/structure/decorative/ed209/on_update_icon()
	. = ..()
	if(anchored)
		pixel_z = 8
	else pixel_z = 0

/obj/structure/decorative/ed209/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!user.skill_check(SKILL_DEVICES, SKILL_BASIC))
		USE_FEEDBACK_FAILURE("You're not skill enough to salvage [src].")
		return
	if(salvaged)
		USE_FEEDBACK_FAILURE("It doesn't seem like there's anything of use left on [src].")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts rummaging through [src] with [tool]."),
		SPAN_NOTICE("You start looking for useful components [src] with [tool].")
	)
	if(!tool.use_as_tool(src, user, 2 SECONDS, volume = 50, skill_path = SKILL_DEVICES, do_flags = DO_REPAIR_CONSTRUCT) || salvaged)
		return
	user.visible_message(
		SPAN_NOTICE("[user] detaches some components from [src] with [tool]."),
		SPAN_NOTICE("You detach some useful components from [src] with [tool].")
	)
	var/obj/item/part = pickweight(loot)
	part = new part(get_turf(user))
	user.put_in_hands(part)
	salvaged = prob(25) //Sometimes more, sometimes less

/obj/structure/decorative/md_slug
	name = "charred mass driver slug"
	desc = "A damaged, and used mass-driver slug. This one has likely seen the broad-end of an armoured hull. It has a small stamp, etched on the side. 'SFV Nathan Hale, INV: 654-2305'. "
	icon = 'icons/obj/munitions.dmi'
	icon_state = "hale_slug"
	var/list/move_sounds = list(
		'sound/effects/metalscrape1.ogg',
		'sound/effects/metalscrape2.ogg',
		'sound/effects/metalscrape3.ogg'
	)
	anchored = FALSE
	density = TRUE

/obj/structure/decorative/md_slug/Move()
	. = ..()
	if(.)
		var/turf/T = get_turf(src)
		if(!isspaceturf(T) && !istype(T, /turf/simulated/floor/carpet))
			playsound(T, pick(move_sounds), 75, 1)
