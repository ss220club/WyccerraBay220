/obj/item/material/twohanded/jack
	name = "maintenance jack"
	desc = "A heavy-duty combination hammer and prying tool that can be used to remove airlock braces."
	icon = 'icons/obj/tools/crowbar.dmi'
	icon_state = "jack0"
	base_icon = "jack"
	w_class = ITEM_SIZE_LARGE
	attack_cooldown = 2.5 * DEFAULT_WEAPON_COOLDOWN
	melee_accuracy_bonus = -25
	throwforce = 15
	force = 25
	force_multiplier = 1.1
	unwielded_force_divisor = 0.7
	attack_cooldown_modifier = 1
	base_parry_chance = 30
	applies_material_colour = FALSE
	tool_behaviour = TOOL_CROWBAR
	usesound = DEFAULT_CROWBAR_SOUND

/obj/item/material/twohanded/jack/aluminium
	default_material = MATERIAL_ALUMINIUM

/obj/item/material/twohanded/jack/titanium
	default_material = MATERIAL_TITANIUM

/obj/item/material/twohanded/jack/silver
	default_material = MATERIAL_SILVER

/obj/item/airlock_brace
	name = "airlock brace"
	desc = "A sturdy device that can be attached to an airlock to reinforce it and provide additional security."
	icon = 'icons/obj/doors/airlock_machines.dmi'
	icon_state = "brace_open"
	health_max = 300
	var/obj/machinery/door/airlock/airlock
	var/obj/item/airlock_electronics/brace/electronics


/obj/item/airlock_brace/Destroy()
	if (airlock)
		airlock.brace = null
		airlock = null
	QDEL_NULL(electronics)
	return ..()


/obj/item/airlock_brace/Initialize()
	. = ..()
	electronics = new (src)
	if (length(req_access))
		electronics.set_access(src)
	update_access()


/obj/item/airlock_brace/on_update_icon()
	if (airlock)
		icon_state = "brace_closed"
	else
		icon_state = "brace_open"


/obj/item/airlock_brace/attack_self(mob/living/user)
	electronics.attack_self(user)

/obj/item/airlock_brace/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!health_damaged())
		USE_FEEDBACK_NOTHING_TO_REPAIR(user)
		return
	if(!tool.tool_start_check(user, 1))
		return
	USE_FEEDBACK_REPAIR_START(user)
	if(!tool.use_as_tool(src, user, 3 SECONDS, 1, 50, SKILL_CONSTRUCTION, do_flags = DO_REPAIR_CONSTRUCT))
		return
	USE_FEEDBACK_REPAIR_FINISH(user)
	restore_health(rand(75, 150))

/obj/item/airlock_brace/attackby(obj/item/item, mob/living/user)
	if (istype(item.GetIdCard(), /obj/item/card/id))
		if (airlock)
			update_access()
			if (check_access(item))
				user.visible_message(
					SPAN_ITALIC("[user] swipes [item] through [src]."),
					SPAN_ITALIC("You swipe [item] through [src]."),
				)
				if (do_after(user, 1 SECOND, airlock, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
					to_chat(user, "[src] clicks and detaches from [airlock]!")
					user.put_in_hands(src)
					airlock.brace = null
					airlock.update_icon()
					airlock = null
					update_icon()
			else
				to_chat(user, "You swipe [item] through [src], but it does not react.")
		else
			attack_self(user)
	if (user.a_intent == I_HURT)
		return ..()
	if (istype(item, /obj/item/material/twohanded/jack))
		if (!airlock)
			return TRUE
		user.visible_message(
			SPAN_ITALIC("[user] begins removing [src] with [item]."),
			SPAN_ITALIC("You begin removing [src] with [item].")
		)
		if (do_after(user, 20 SECONDS, airlock, DO_DEFAULT | DO_USER_UNIQUE_ACT | DO_PUBLIC_PROGRESS))
			user.visible_message(
				SPAN_ITALIC("[user] removes [src] with [item]."),
				SPAN_ITALIC("You remove [src] with [item].")
			)
			user.put_in_hands(src)
			airlock.brace = null
			airlock.update_icon()
			airlock = null
			update_icon()
		return TRUE

/obj/item/airlock_brace/on_death()
	if (airlock)
		visible_message(SPAN_DANGER("[src] breaks, falling from [airlock]!"))
		airlock.brace = null
		airlock.update_icon()
	qdel(src)


/obj/item/airlock_brace/proc/update_access()
	if (!electronics)
		return
	req_access = electronics.conf_access
	if (electronics.one_access)
		req_access = list(req_access)
