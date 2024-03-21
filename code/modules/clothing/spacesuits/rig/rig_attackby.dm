/obj/item/rig/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!open && locked)
		to_chat(user, SPAN_NOTICE("The access panel is locked shut."))
		return
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	open = !open
	to_chat(user, SPAN_NOTICE("You [open ? "open" : "close"] the access panel."))

/obj/item/rig/multitool_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!p_open)
		to_chat(user, "You can't reach the wiring.")
		return
	wires.Interact(user)

/obj/item/rig/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	p_open = !p_open
	USE_FEEDBACK_NEW_PANEL_OPEN(user, p_open)

/obj/item/rig/wrench_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!open)
		return
	var/list/current_mounts = list()
	if(cell)
		current_mounts += "cell"
	if(air_supply)
		current_mounts += "tank"
	if(istype(chest, /obj/item/clothing/suit/space/rig))
		if(length(chest?.storage?.contents))
			current_mounts += "storage"
	if(installed_modules && length(installed_modules))
		current_mounts += "system module"
	var/to_remove = input("Which would you like to modify?") as null|anything in current_mounts
	if(!to_remove)
		return
	if(istype(src.loc,/mob/living/carbon/human) && to_remove != "cell" && to_remove != "tank")
		var/mob/living/carbon/human/H = src.loc
		if(H.back == src)
			to_chat(user, "You can't remove an installed device while the hardsuit is being worn.")
			return
	switch(to_remove)
		if("cell")
			if(!cell)
				to_chat(user, "There is nothing loaded in that mount.")
				return
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			to_chat(user, "You detach [cell] from [src]'s battery mount.")
			for(var/obj/item/rig_module/module in installed_modules)
				module.deactivate()
			user.put_in_hands(cell)
			cell = null
		if("tank")
			if(!air_supply)
				to_chat(user, "There is no tank to remove.")
				return
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			user.put_in_hands(air_supply)
			to_chat(user, "You detach and remove [air_supply].")
			air_supply = null
		if("storage")
			if (!length(chest?.storage?.contents))
				to_chat(user, "There is nothing in the storage to remove.")
				return
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			chest.storage.DoQuickEmpty()
			user.visible_message(
				SPAN_ITALIC("[user] ejects the contents of [src]'s storage."),
				SPAN_ITALIC("You eject the contents of [src]'s storage."),
				SPAN_ITALIC("You hear things clatter to the floor."),
				range = 5
			)
		if("system module")
			var/list/possible_removals = list()
			for(var/obj/item/rig_module/module in installed_modules)
				if(module.permanent)
					continue
				possible_removals[module.name] = module
			if(!length(possible_removals))
				to_chat(user, "There are no installed modules to remove.")
				return
			var/removal_choice = input("Which module would you like to remove?") as null|anything in possible_removals
			if(!removal_choice)
				return
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			var/obj/item/rig_module/removed = possible_removals[removal_choice]
			to_chat(user, "You detach [removed] from [src].")
			removed.dropInto(loc)
			removed.removed()
			installed_modules -= removed
			update_icon()

/obj/item/rig/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!p_open)
		to_chat(user, "You can't reach the wiring.")
		return
	wires.Interact(user)

/obj/item/rig/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(chest)
		return chest.welder_act(tool, user)

/obj/item/rig/attackby(obj/item/W as obj, mob/user as mob)
	if(!isliving(user))
		return

	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return

	// Pass repair items on to the chestpiece.
	if(chest && istype(W,/obj/item/stack/material))
		return W.resolve_attackby(chest, user)

	// Lock or unlock the access panel.
	if(W.GetIdCard())
		if(subverted)
			locked = 0
			to_chat(user, SPAN_DANGER("It looks like the locking system has been shorted out."))
			return

		if(!length(req_access))
			locked = 0
			to_chat(user, SPAN_DANGER("[src] doesn't seem to have a locking mechanism."))
			return

		if(security_check_enabled && !src.allowed(user))
			to_chat(user, SPAN_DANGER("Access denied."))
			return

		locked = !locked
		to_chat(user, "You [locked ? "lock" : "unlock"] [src] access panel.")
		return
	if(open)
		// Air tank.
		if(istype(W,/obj/item/tank)) //Todo, some kind of check for suits without integrated air supplies.

			if(air_supply)
				to_chat(user, "[src] already has a tank installed.")
				return
			if (istype(W, /obj/item/tank/scrubber))
				to_chat(user, SPAN_WARNING("[W] is far too large to attach to [src]."))
				return

			if(!user.unEquip(W)) return
			air_supply = W
			W.forceMove(src)
			to_chat(user, "You slot [W] into [src] and tighten the connecting valve.")
			return

		// Check if this is a hardsuit upgrade or a modification.
		else if(istype(W,/obj/item/rig_module))
			var/obj/item/rig_module/mod = W
			if (!mod.can_install(src, user))
				return TRUE

			to_chat(user, "You begin installing [mod] into [src].")
			if(!do_after(user, 4 SECONDS, src, DO_PUBLIC_UNIQUE))
				return
			if(!user || !W || !mod.can_install(src, user))
				return
			if(!user.unEquip(mod)) return
			to_chat(user, "You install [mod] into [src].")
			LAZYADD(installed_modules, mod)
			installed_modules |= mod
			mod.forceMove(src)
			mod.installed(src)
			update_icon()
			return 1

		else if(!cell && istype(W,/obj/item/cell))

			if(!user.unEquip(W)) return
			to_chat(user, "You jack [W] into [src]'s battery mount.")
			W.forceMove(src)
			src.cell = W
			return

		else if(istype(W,/obj/item/stack/nanopaste)) //EMP repair
			var/obj/item/stack/S = W
			if(malfunctioning || malfunction_delay)
				if(S.use(1))
					to_chat(user, "You pour some of [S] over [src]'s control circuitry and watch as the nanites do their work with impressive speed and precision.")
					malfunctioning = 0
					malfunction_delay = 0
				else
					to_chat(user, "[S] is empty!")
			else
				to_chat(user, "You don't see any use for [S].")

		return

	// If we've gotten this far, all we have left to do before we pass off to root procs
	// is check if any of the loaded modules want to use the item we've been given.
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(W,user)) //Item is handled in this proc
			return
	..()


/obj/item/rig/attack_hand(mob/user)

	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return
	..()

/obj/item/rig/emag_act(remaining_charges, mob/user)
	if(!subverted)
		req_access.Cut()
		locked = 0
		subverted = 1
		to_chat(user, SPAN_DANGER("You short out the access protocol for the suit."))
		return 1
