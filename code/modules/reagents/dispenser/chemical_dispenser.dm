#define MIN_AMOUNT_PER_TRANSFER 0
#define MAX_AMOUNT_PER_TRANSFER 120

/obj/machinery/chemical_dispenser
	name = "chemical dispenser"
	icon = 'icons/obj/machines/dispensers.dmi'
	icon_state = "dispenser"
	layer = BELOW_OBJ_LAYER
	clicksound = "button"
	clickvol = 20
	idle_power_usage = 100
	density = TRUE
	anchored = TRUE
	obj_flags = OBJ_FLAG_ANCHORABLE | OBJ_FLAG_ROTATABLE | OBJ_FLAG_CAN_TABLE
	core_skill = SKILL_CHEMISTRY
	/// Determines if `/obj/item/reagent_containers/food` is accepted as `container`
	var/accept_drinking = FALSE
	/// Amount of reagent we want to move from cartridge to container per transfer
	var/amount_per_transfer = 30
	/// Determines if low core skill affects transfered reagents.
	/// For example, if user has low core skill, random reagents can be added on transfer
	var/can_contaminate = TRUE
	/// Reagent container currently inserted into chem dispanser
	var/obj/item/reagent_containers/container = null
	/// Set to a list of types to spawn one of each on New()
	var/list/spawn_cartridges = null
	/// Associative, label -> cartridge
	var/list/cartridges = list()

/obj/machinery/chemical_dispenser/Initialize()
	. = ..()
	if(!length(spawn_cartridges))
		return

	for(var/type in spawn_cartridges)
		add_cartridge(new type(src))

/obj/machinery/chemical_dispenser/examine(mob/user)
	. = ..()
	to_chat(user, "It has [length(cartridges)] cartridges installed, and has space for [DISPENSER_MAX_CARTRIDGES - length(cartridges)] more.")

/obj/machinery/chemical_dispenser/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	var/label = tgui_input_list(user, "Which cartridge would you like to remove?", "Chemical Dispenser", cartridges)
	remove_cartridge(user, tool, label)

/obj/machinery/chemical_dispenser/use_tool(obj/item/W, mob/living/user, list/click_params)
	if (istype(W, /obj/item/reagent_containers/chem_disp_cartridge))
		add_cartridge(W, user)
		return TRUE

	if (istype(W, /obj/item/reagent_containers/glass) || istype(W, /obj/item/reagent_containers/food) || istype(W, /obj/item/reagent_containers/ivbag))
		if(container)
			to_chat(user, SPAN_WARNING("There is already \a [container] on [src]!"))
			return TRUE

		var/obj/item/reagent_containers/RC = W

		if(!accept_drinking && istype(RC, /obj/item/reagent_containers/food))
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

	data["amount"] = amount_per_transfer
	data["isBeakerLoaded"] = !!container
	data["drinkingGlass"] = accept_drinking

	var/list/beakerContents = list()
	if(length(container?.reagents?.reagent_list))
		for(var/datum/reagent/reagent in container.reagents.reagent_list)
			beakerContents += list(list(
				"name" = reagent.name,
				"volume" = reagent.volume
			))
	data["beakerContents"] = beakerContents

	if(container?.reagents)
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
			return set_amount_per_transfer(text2num(params["amount"]))
		if("dispense")
			return dispense_from_cartridge(usr, params["dispense"])
		if("flush")
			return eject_beaker(usr)

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
		AddOverlays(image('icons/obj/machines/dispensers.dmi', src, "lil_beaker", pixel_x = rand(-10, 5)))

/obj/machinery/chemical_dispenser/proc/eject_beaker(mob/user)
	if(!container)
		return FALSE

	user.put_in_hands(container)
	container = null
	update_icon()
	return TRUE

/obj/machinery/chemical_dispenser/proc/add_cartridge(obj/item/reagent_containers/chem_disp_cartridge/new_cartridge, mob/user)
	if(!istype(new_cartridge))
		if(user)
			to_chat(user, SPAN_WARNING("[new_cartridge] will not fit in [src]!"))
		return

	if(length(cartridges) >= DISPENSER_MAX_CARTRIDGES)
		if(user)
			to_chat(user, SPAN_WARNING("[src] does not have any slots open for [new_cartridge] to fit into!"))
		return

	if(!new_cartridge.label)
		if(user)
			to_chat(user, SPAN_WARNING("[new_cartridge] does not have a label!"))
		return

	if(cartridges[new_cartridge.label])
		if(user)
			to_chat(user, SPAN_WARNING("[src] already contains a cartridge with that label!"))
		return

	if(user)
		if(user.unEquip(new_cartridge))
			to_chat(user, SPAN_NOTICE("You add [new_cartridge] to [src]."))
		else
			return

	new_cartridge.forceMove(src)
	cartridges[new_cartridge.label] = new_cartridge
	cartridges = sortAssoc(cartridges)
	SStgui.update_uis(src)

/**
 * Sets the amount per transfer.
 *
 ** Arguments:
 * new_amount - amount per transfer we want to set
 *
 * Returns: TRUE if `amount_per_transfer` has changed to `new_amount`, FALSE otherwise
 */
/obj/machinery/chemical_dispenser/proc/set_amount_per_transfer(new_amount)
	PRIVATE_PROC(TRUE)

	new_amount = clamp(round(new_amount, 1), MIN_AMOUNT_PER_TRANSFER, MAX_AMOUNT_PER_TRANSFER)
	if(new_amount == amount_per_transfer)
		return FALSE

	amount_per_transfer = new_amount
	return TRUE

/**
 * Removes desired cartridge from chem dispanser.
 *
 ** Arguments:
 * user - user trying to remove cartridge
 * screwdriver - scredriver used to remove cartridge
 * cartridge_to_remove_label - label of cartridge user wants to remove
 */
/obj/machinery/chemical_dispenser/proc/remove_cartridge(mob/user, obj/item/screwdriver, cartridge_to_remove_label)
	PRIVATE_PROC(TRUE)

	if(!cartridge_to_remove_label)
		return

	var/obj/item/reagent_containers/chem_disp_cartridge/cartridge_to_remove = cartridges[cartridge_to_remove_label]
	if(!cartridge_to_remove)
		return

	if(!screwdriver.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return

	cartridge_to_remove.dropInto(loc)
	cartridges -= cartridge_to_remove_label
	balloon_alert(user, "[cartridge_to_remove] снят")
	SStgui.update_uis(src)

/**
 * Add random amount of reagent from random amount of cartridges, depending on user core skill level.
 ** Argument:
 * cartridge_to_exclude_label - label of cartridge we don't want to use as contaminant
 *
 * Returns: amount of contaminant reagents added
 */
/obj/machinery/chemical_dispenser/proc/dispense_from_cartridge(mob/user, dispense_from_cartridge_label)
	PRIVATE_PROC(TRUE)

	if(!user || !dispense_from_cartridge_label || !container?.is_open_container())
		return FALSE

	var/obj/item/reagent_containers/chem_disp_cartridge/dispence_from = cartridges[dispense_from_cartridge_label]
	if(!dispence_from)
		return FALSE

	var/deviation = 1 + (-0.5 + round(rand(), 0.1)) * user.skill_fail_chance(core_skill, 0.3, SKILL_TRAINED)
	var/transfered_reagents_amount = dispence_from.reagents.trans_to(container, amount_per_transfer * deviation)
	if(can_contaminate)
		var/contaminant_transfered = contaminate_container(user, dispense_from_cartridge_label)
		transfered_reagents_amount += contaminant_transfered

	return transfered_reagents_amount > 0

/**
 * Add random amount of reagent from random amount of cartridges to current `container`, depending on user core skill level.
 ** Argument:
 * cartridge_to_exclude_label - label of cartridge we don't want to use as contaminant
 *
 * Returns: amount of contaminant reagents added
 */
/obj/machinery/chemical_dispenser/proc/contaminate_container(mob/user, cartridge_to_exclude_label)
	PRIVATE_PROC(TRUE)

	ASSERT(container?.is_open_container())
	ASSERT(user)

	var/contaminants_left = rand(0, max(SKILL_TRAINED - user.get_skill_value(core_skill), 0))
	if(!contaminants_left)
		return 0

	var/choices = cartridges.Copy() - cartridge_to_exclude_label
	var/contaminant_amount_transfered = 0
	for(var/contamination_act_index in 1 to contaminants_left)
		if(!length(choices))
			break

		var/obj/item/reagent_containers/chem_disp_cartridge/choice = cartridges[pick_n_take(choices)]
		contaminant_amount_transfered += choice.reagents.trans_to(container, round(rand() * amount_per_transfer / 5, 0.1))

	return contaminant_amount_transfered

#undef MIN_AMOUNT_PER_TRANSFER
#undef MAX_AMOUNT_PER_TRANSFER
