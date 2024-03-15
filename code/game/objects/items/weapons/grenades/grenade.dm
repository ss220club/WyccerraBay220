/obj/item/grenade
	name = "grenade"
	desc = "A hand held grenade, with an adjustable timer."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "grenade"
	item_state = "grenade"
	throw_speed = 4
	throw_range = 20
	obj_flags = OBJ_FLAG_CONDUCTIBLE
	slot_flags = SLOT_BELT
	var/active = 0
	var/det_time = 50
	var/fail_det_time = 5 // If you are clumsy and fail, you get this time.
	var/arm_sound = 'sound/weapons/armbomb.ogg'


/obj/item/grenade/proc/clown_check(mob/living/user)
	if((MUTATION_CLUMSY in user.mutations) && prob(50))
		to_chat(user, SPAN_WARNING("Huh? How does this thing work?"))
		det_time = fail_det_time
		activate(user)
		add_fingerprint(user)
		return 0
	return 1


/obj/item/grenade/examine(mob/user, distance)
	. = ..()
	if(distance <= 0)
		if(det_time > 1)
			to_chat(user, "The timer is set to [det_time/10] seconds.")
			return
		if(isnull(det_time))
			return
		to_chat(user, "\The [src] is set for instant detonation.")


/obj/item/grenade/attack_self(mob/living/user)
	if(!active)
		if(clown_check(user))
			to_chat(user, SPAN_WARNING("You prime \the [name]! [det_time/10] seconds!"))
			activate(user)
			add_fingerprint(user)
			if(iscarbon(user))
				var/mob/living/carbon/C = user
				C.throw_mode_on()


/obj/item/grenade/proc/activate(mob/living/user)
	if (active)
		return
	if (user)
		msg_admin_attack("[user.name] ([user.ckey]) primed \a [src] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	icon_state = initial(icon_state) + "_active"
	active = TRUE
	playsound(loc, arm_sound, 75, 0, -3)
	addtimer(CALLBACK(src, PROC_REF(detonate), user), det_time)


/obj/item/grenade/proc/detonate(mob/living/user)
	var/turf/T = get_turf(src)
	if(T)
		T.hotspot_expose(700,125)

/obj/item/grenade/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	switch(det_time)
		if(1)
			det_time = 1 SECONDS
			balloon_alert(user, "1 секунда")
		if(1 SECONDS)
			det_time = 3 SECONDS
			balloon_alert(user, "3 секунды")
		if(3 SECONDS)
			det_time = 5 SECONDS
			balloon_alert(user, "5 секунд")
		if(5 SECONDS)
			det_time = 1
			balloon_alert(user, "мгновенная детонация")
	add_fingerprint(user)

/obj/item/grenade/attack_hand()
	walk(src, null, null)
	..()
