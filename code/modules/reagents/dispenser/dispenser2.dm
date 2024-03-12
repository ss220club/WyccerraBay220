/obj/machinery/chemical_dispenser
	name = "chemical dispenser"
	icon = 'icons/obj/machines/dispensers.dmi'
	icon_state = "dispenser"
	layer = BELOW_OBJ_LAYER
	clicksound = "button"
	clickvol = 20

	var/list/spawn_cartridges = null // Set to a list of types to spawn one of each on New()

	var/list/cartridges = list() // Associative, label -> cartridge
	var/obj/item/reagent_containers/container = null

	var/ui_title = "Chemical Dispenser"

	var/accept_drinking = 0
	var/amount = 30

	idle_power_usage = 100
	density = TRUE
	anchored = TRUE
	obj_flags = OBJ_FLAG_ANCHORABLE | OBJ_FLAG_ROTATABLE | OBJ_FLAG_CAN_TABLE
	core_skill = SKILL_CHEMISTRY
	var/can_contaminate = TRUE

/obj/machinery/chemical_dispenser/New()
	..()

	if(spawn_cartridges)
		for(var/type in spawn_cartridges)
			add_cartridge(new type(src))

/obj/machinery/chemical_dispenser/examine(mob/user)
	. = ..()
	to_chat(user, "It has [length(cartridges)] cartridges installed, and has space for [DISPENSER_MAX_CARTRIDGES - length(cartridges)] more.")

/obj/machinery/chemical_dispenser/proc/add_cartridge(obj/item/reagent_containers/chem_disp_cartridge/C, mob/user)
	if(!istype(C))
		if(user)
			to_chat(user, SPAN_WARNING("[C] will not fit in [src]!"))
		return

	if(length(cartridges) >= DISPENSER_MAX_CARTRIDGES)
		if(user)
			to_chat(user, SPAN_WARNING("[src] does not have any slots open for [C] to fit into!"))
		return

	if(!C.label)
		if(user)
			to_chat(user, SPAN_WARNING("[C] does not have a label!"))
		return

	if(cartridges[C.label])
		if(user)
			to_chat(user, SPAN_WARNING("[src] already contains a cartridge with that label!"))
		return

	if(user)
		if(user.unEquip(C))
			to_chat(user, SPAN_NOTICE("You add [C] to [src]."))
		else
			return

	C.forceMove(src)
	cartridges[C.label] = C
	cartridges = sortAssoc(cartridges)
	SStgui.update_uis(src)

/obj/machinery/chemical_dispenser/proc/remove_cartridge(label)
	. = cartridges[label]
	cartridges -= label
	SStgui.update_uis(src)

/obj/machinery/chemical_dispenser/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	var/label = input(user, "Which cartridge would you like to remove?", "Chemical Dispenser") as null|anything in cartridges
	if(!label)
		return
	var/obj/item/reagent_containers/chem_disp_cartridge/C = remove_cartridge(label)
	if(C)
		if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
			return
		to_chat(user, SPAN_NOTICE("You remove [C] from [src]."))
		C.dropInto(loc)

/obj/machinery/chemical_dispenser/use_tool(obj/item/W, mob/living/user, list/click_params)
	if (istype(W, /obj/item/reagent_containers/chem_disp_cartridge))
		add_cartridge(W, user)
		return TRUE

	if (istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food) || istype(W, /obj/item/reagent_containers/ivbag))
		if(container)
			to_chat(user, SPAN_WARNING("There is already \a [container] on [src]!"))
			return TRUE

		var/obj/item/reagent_containers/RC = W

		if(!accept_drinking && istype(RC,/obj/item/reagent_containers/food))
			to_chat(user, SPAN_WARNING("This machine only accepts beakers and IV bags!"))
			return TRUE

		if(!RC.is_open_container())
			to_chat(user, SPAN_WARNING("You don't see how [src] could dispense reagents into [RC]."))
			return TRUE
		if(!user.unEquip(RC, src))
			return TRUE
		container =  RC
		update_icon()
		to_chat(user, SPAN_NOTICE("You set [RC] on [src]."))
		SStgui.update_uis(src)
		return TRUE

	return ..()

/obj/machinery/chemical_dispenser/proc/eject_beaker(mob/user)
	if(!container)
		return
	var/obj/item/reagent_containers/B = container
	user.put_in_hands(B)
	container = null
	update_icon()

/obj/machinery/chemical_dispenser/interface_interact(mob/user)
	tgui_interact(user)
	return TRUE

/obj/machinery/chemical_dispenser/tgui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chemical_dispenser/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemDispenser", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/chemical_dispenser/tgui_data(mob/user)
	var/list/data = list()

	data["amount"] = amount
	data["isBeakerLoaded"] = container ? TRUE : FALSE
	data["drinkingGlass"] = accept_drinking

	var/list/beakerContents = list()
	if(container && container.reagents && length(container.reagents.reagent_list))
		for(var/datum/reagent/reagent in container.reagents.reagent_list)
			beakerContents += list(list(
				"name" = reagent.name,
				"volume" = reagent.volume
			))
	data["beakerContents"] = beakerContents

	if(container)
		data["beakerCurrentVolume"] = container.reagents.total_volume
		data["beakerMaxVolume"] = container.reagents.maximum_volume
	else
		data["beakerCurrentVolume"] = null
		data["beakerMaxVolume"] = null

	var/list/chemicals = list()
	for(var/label in cartridges)
		var/obj/item/reagent_containers/chem_disp_cartridge/cartridge = cartridges[label]
		chemicals += list(list(
			"label" = label,
			"amount" = cartridge.reagents.total_volume
		))
	data["chemicals"] = chemicals

	return data

/obj/machinery/chemical_dispenser/tgui_act(action, params)
	if(..())
		return

	switch(action)
		if("amount")
			amount = round(text2num(params["amount"]), 1)
			amount = max(0, min(120, amount))
			return TRUE
		if("dispense")
			var/label = params["dispense"]
			if(cartridges[label] && container && container.is_open_container())
				var/obj/item/reagent_containers/chem_disp_cartridge/C = cartridges[label]
				var/mult = 1 + (-0.5 + round(rand(), 0.1)) * (usr.skill_fail_chance(core_skill, 0.3, SKILL_TRAINED))
				C.reagents.trans_to(container, amount * mult)
				var/contaminants_left = rand(0, max(SKILL_TRAINED - usr.get_skill_value(core_skill), 0)) * can_contaminate
				var/choices = cartridges.Copy()
				while(length(choices) && contaminants_left)
					var/chosen_label = pick_n_take(choices)
					var/obj/item/reagent_containers/chem_disp_cartridge/choice = cartridges[chosen_label]
					if(choice == C)
						continue
					choice.reagents.trans_to(container, round(rand() * amount / 5, 0.1))
					contaminants_left--
				return TRUE
			return FALSE
		if("flush")
			eject_beaker(usr)
			return TRUE

/obj/machinery/chemical_dispenser/AltClick(mob/user)
	if(CanDefaultInteract(user))
		eject_beaker(user)
		return TRUE
	return ..()

/obj/machinery/chemical_dispenser/on_update_icon()
	ClearOverlays()
	if(is_powered())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")
	if(container)
		var/mutable_appearance/beaker_overlay
		beaker_overlay = image('icons/obj/machines/dispensers.dmi', src, "lil_beaker")
		beaker_overlay.pixel_x = rand(-10, 5)
		AddOverlays(beaker_overlay)
