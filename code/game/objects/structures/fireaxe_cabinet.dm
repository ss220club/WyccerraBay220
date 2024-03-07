/obj/structure/fireaxecabinet
	name = "fire axe cabinet"
	desc = "There is small label that reads \"For Emergency use only\" along with details for safe use of the axe. As if."
	icon_state = "fireaxe"
	anchored = TRUE
	density = FALSE
	health_max = 30
	health_min_damage = 15
	damage_hitsound = 'sound/effects/Glasshit.ogg'

	var/open
	var/unlocked
	var/obj/item/material/twohanded/fireaxe/fireaxe

/obj/structure/fireaxecabinet/on_death()
	playsound(src, 'sound/effects/Glassbr3.ogg', 50, TRUE)
	open = TRUE
	unlocked = TRUE
	update_icon()

/obj/structure/fireaxecabinet/on_revive()
	update_icon()

/obj/structure/fireaxecabinet/on_update_icon()
	ClearOverlays()
	if(fireaxe)
		AddOverlays(image(icon, "fireaxe_item"))
	if(health_dead)
		AddOverlays(image(icon, "fireaxe_window_broken"))
	else if(!open)
		AddOverlays(image(icon, "fireaxe_window"))

/obj/structure/fireaxecabinet/New()
	..()
	fireaxe = new(src)
	update_icon()

/obj/structure/fireaxecabinet/attack_hand(mob/user)
	if(!unlocked)
		to_chat(user, SPAN_WARNING("[src] is locked."))
		return
	toggle_open(user)

/obj/structure/fireaxecabinet/MouseDrop(over_object, src_location, over_location)
	if(over_object == usr)
		var/mob/user = over_object
		if(!istype(user))
			return

		if(!open)
			to_chat(user, SPAN_WARNING("[src] is closed."))
			return

		if(!fireaxe)
			to_chat(user, SPAN_WARNING("[src] is empty."))
			return

		user.put_in_hands(fireaxe)
		fireaxe = null
		update_icon()

	return

/obj/structure/fireaxecabinet/Destroy()
	if(fireaxe)
		fireaxe.dropInto(loc)
		fireaxe = null
	return ..()

/obj/structure/fireaxecabinet/multitool_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(open)
		USE_FEEDBACK_FAILURE("[src] must be closed before you can lock it.")
		return
	if(health_dead)
		USE_FEEDBACK_FAILURE("[src] is shattered and the lock doesn't function.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] begins toggling [src]'s maglock with [tool]."),
		SPAN_NOTICE("You begin [unlocked ? "locking" : "unlocking"] [src]'s maglock with [tool].")
	)
	if(!tool.use_as_tool(src, user, 2 SECONDS, volume = 50, skill_path = list(SKILL_DEVICES, SKILL_CONSTRUCTION), do_flags = DO_PUBLIC_UNIQUE))
		return
	playsound(src, 'sound/machines/lockreset.ogg', 50, TRUE)
	unlocked = !unlocked
	update_icon()
	user.visible_message(
		SPAN_NOTICE("[user] [unlocked ? "unlocks" : "locks"] [src]'s maglock with [tool]."),
		SPAN_NOTICE("You [unlocked ? "unlock" : "lock"] [src]'s maglock with [tool].")
	)

/obj/structure/fireaxecabinet/use_tool(obj/item/tool, mob/user, list/click_params)
	// Fireaxe - Place inside
	if (istype(tool, /obj/item/material/twohanded/fireaxe))
		if (!open)
			USE_FEEDBACK_FAILURE("[src] is closed.")
			return TRUE
		if (fireaxe)
			USE_FEEDBACK_FAILURE("[src] already has [fireaxe] inside.")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		fireaxe = tool
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] places [tool] into [src]."),
			SPAN_NOTICE("You place [tool] into [src].")
		)
		return TRUE

	// Material Stack - Repair damage
	if (istype(tool, /obj/item/stack/material))
		var/obj/item/stack/material/stack = tool
		if (stack.material.name != MATERIAL_GLASS)
			return ..()
		if (!health_dead && !health_damaged())
			USE_FEEDBACK_FAILURE("[src] doesn't need repair.")
			return TRUE
		if (!stack.reinf_material)
			USE_FEEDBACK_FAILURE("[src] can only be repaired with reinforced glass.")
			return TRUE
		if (!stack.use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(stack, 1, "to repair [src].")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] repairs [src]'s damage with [stack.get_vague_name(FALSE)]."),
			SPAN_NOTICE("You repair [src]'s damage with [stack.get_exact_name(1)].")
		)
		revive_health()
		return TRUE

/obj/structure/fireaxecabinet/proc/toggle_open(mob/user)
	if(health_dead)
		open = 1
		unlocked = 1
	else
		user.setClickCooldown(10)
		open = !open
		to_chat(user, SPAN_NOTICE("You [open ? "open" : "close"] [src]."))
	update_icon()
