
/* SmartFridge.  Much todo
*/
/obj/machinery/smartfridge
	name = "\improper SmartFridge"
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "fridge_sci"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	anchored = TRUE
	idle_power_usage = 5
	active_power_usage = 100
	atom_flags = ATOM_FLAG_NO_TEMP_CHANGE | ATOM_FLAG_NO_REACT
	obj_flags = OBJ_FLAG_ANCHORABLE | OBJ_FLAG_ROTATABLE

	var/icon_base = "fridge_sci"
	var/icon_contents = "chem"
	var/locked = 0
	var/datum/stored_items/currently_vending = null
	/// Associative list (/obj/item => /number) representing the items the fridge should initially contain.
	var/list/item_records = list()
	/// The maximum number of items the fridge can hold. Multiplicated by the matter bin component's rating.
	var/static/max_n_of_items = 999
	/// How long in ticks the fridge is electrified for. Decrements every process.
	var/seconds_electrified = 0
	/// Whether the fridge should randomly shoot held items at a nearby living target or not.
	var/shoot_inventory = FALSE
	/// Whether the fridge requires ID scanning. Used for the secure variant of the fridge.
	var/scan_id = TRUE
	/// Whether the fridge is considered secure. Used for wiring and display.
	var/is_secure = FALSE
	/// Whether the fridge can dry its' contents. Used for display.
	var/can_dry = FALSE
	/// Whether the fridge is currently drying. Used by [drying racks][/obj/machinery/smartfridge/drying_rack].
	var/drying = FALSE
	/// List of type paths this fridge accepts.
	var/list/accepted_types = list(
		/obj/item/reagent_containers/food/snacks/grown,
		/obj/item/seeds,
		/obj/item/shellfish
	)

/obj/machinery/smartfridge/secure
	is_secure = TRUE

/obj/machinery/smartfridge/New()
	. = ..()
	if(is_secure)
		wires = new/datum/wires/smartfridge/secure(src)
	else
		wires = new/datum/wires/smartfridge(src)
	update_icon()

/obj/machinery/smartfridge/Destroy()
	for(var/datum/stored_items/S in item_records)
		qdel(S)
	item_records = null
	return ..()

/obj/machinery/smartfridge/get_req_access()
	if(!scan_id)
		return list()
	return ..()

/obj/machinery/smartfridge/Process()
	if(inoperable())
		return
	if(src.seconds_electrified > 0)
		src.seconds_electrified--
	if(src.shoot_inventory && prob(2))
		src.throw_item()

/obj/machinery/smartfridge/on_update_icon()
	ClearOverlays()
	if(inoperable())
		icon_state = "[icon_base]-off"
	else
		icon_state = icon_base

	if(is_secure)
		AddOverlays(image(icon, "[icon_base]-sidepanel"))

	if(panel_open)
		AddOverlays(image(icon, "[icon_base]-panel"))

	var/image/I
	var/is_off = ""
	if(inoperable())
		is_off = "-off"

	// Fridge contents
	switch(length(contents))
		if(0)
			I = image(icon, "empty[is_off]")
		if(1 to 2)
			I = image(icon, "[icon_contents]-1[is_off]")
		if(3 to 5)
			I = image(icon, "[icon_contents]-2[is_off]")
		if(6 to 8)
			I = image(icon, "[icon_contents]-3[is_off]")
		else
			I = image(icon, "[icon_contents]-4[is_off]")
	AddOverlays(I)

	// Fridge top
	I = image(icon, "[icon_base]-top")
	I.pixel_z = 32
	I.layer = ABOVE_WINDOW_LAYER
	AddOverlays(I)

/obj/machinery/smartfridge/multitool_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(panel_open)
		attack_hand(user)

/obj/machinery/smartfridge/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
		return
	panel_open = !panel_open
	USE_FEEDBACK_NEW_PANEL_OPEN(user, panel_open)
	update_icon()
	SSnano.update_uis(src)

/obj/machinery/smartfridge/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(panel_open)
		attack_hand(user)

/obj/machinery/smartfridge/use_tool(obj/item/O, mob/living/user, list/click_params)
	if(!is_powered())
		to_chat(user, SPAN_NOTICE("[src] is unpowered and useless."))
		return TRUE

	if(accept_check(O))
		if(!user.unEquip(O))
			return TRUE
		stock_item(O)
		user.visible_message(SPAN_NOTICE("[user] has added [O] to [src]."), SPAN_NOTICE("You add [O] to [src]."))
		update_icon()
		return TRUE

	else if(istype(O, /obj/item/storage))
		var/obj/item/storage/bag/P = O
		var/plants_loaded = 0
		for(var/obj/G in P.contents)
			if(accept_check(G) && P.remove_from_storage(G, src, 1))
				plants_loaded++
				stock_item(G)
		P.finish_bulk_removal()

		if(plants_loaded)
			user.visible_message(SPAN_NOTICE("[user] loads [src] with the contents of [P]."), SPAN_NOTICE("You load [src] with the contents of [P]."))
			if(length(P.contents) > 0)
				to_chat(user, SPAN_NOTICE("Some items were refused."))
		return TRUE
	return ..()

/obj/machinery/smartfridge/secure/emag_act(remaining_charges, mob/user)
	if(!emagged)
		emagged = TRUE
		locked = -1
		req_access.Cut()
		to_chat(user, "You short out the product lock on [src].")
		return TRUE

/obj/machinery/smartfridge/interface_interact(mob/user)
	tgui_interact(user)
	return TRUE

/obj/machinery/smartfridge/tgui_state(mob/user)
	return GLOB.tgui_default_state

/obj/machinery/smartfridge/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SmartFridge", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/smartfridge/tgui_data(mob/user)
	var/list/data = list()

	data["contents"] = null
	data["secure"] = is_secure
	data["can_dry"] = can_dry
	data["drying"] = drying

	var/list/items = list()
	for(var/i=1 to length(item_records))
		var/datum/stored_items/I = item_records[i]
		var/count = I.get_amount()
		if(count > 0)
			items += list(list(
				"display_name" = I.item_name,
				"vend" = i,
				"quantity" = count
				))

	if(length(items) > 0)
		data["contents"] = items

	return data

/obj/machinery/smartfridge/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("vend")
			if(is_secure && !allowed(usr) && !emagged && locked != -1 && scan_id)
				to_chat(usr, SPAN_WARNING("Отказано в доступе."))
				return FALSE

			var/index = text2num(params["vend"])
			var/amount = text2num(params["amount"])
			var/datum/stored_items/I = item_records[index]
			var/count = I.get_amount()
			if(count > 0)
				if((count - amount) < 0)
					amount = count
				for(var/i = 1 to amount)
					I.get_product(get_turf(src))
					update_icon()

			return TRUE

/obj/machinery/smartfridge/proc/accept_check(obj/item/O)
	if(is_type_in_list(O, accepted_types))
		return TRUE
	return FALSE

/obj/machinery/smartfridge/proc/stock_item(obj/item/O)
	for(var/datum/stored_items/I in item_records)
		if(istype(O, I.item_path) && O.name == I.item_name)
			stock(I, O)
			return

	var/datum/stored_items/I = new/datum/stored_items(src, O.type, O.name)
	dd_insertObjectList(item_records, I)
	stock(I, O)

/obj/machinery/smartfridge/proc/stock(datum/stored_items/I, obj/item/O)
	I.add_product(O)
	SStgui.update_uis(src)

/obj/machinery/smartfridge/proc/throw_item()
	var/obj/throw_item
	var/mob/living/target = locate() in view(7, src)
	if(!target)
		return FALSE

	for(var/datum/stored_items/I in src.item_records)
		throw_item = I.get_product(loc)
		if(!throw_item)
			continue
		break

	if(!throw_item)
		return FALSE

	spawn(0)
		throw_item.throw_at(target, 16, 3)
	src.visible_message(SPAN_WARNING("[src] launches [throw_item.name] at [target.name]!"))
	update_icon()
	return TRUE

/obj/machinery/smartfridge/drying_rack
	name = "drying rack"
	desc = "A machine for drying plants."
	icon_state = "drying_rack"
	can_dry = TRUE
	accepted_types = null

/obj/machinery/smartfridge/drying_rack/accept_check(obj/item/O)
	if(istype(O, /obj/item/reagent_containers/food/snacks))
		var/obj/item/reagent_containers/food/snacks/S = O
		return S.dried_type ? TRUE : FALSE
	else if(istype(O, /obj/item/stack/material))
		var/obj/item/stack/material/mat = O
		var/material/skin/skin_mat = mat.material
		return istype(skin_mat)
	return FALSE

/obj/machinery/smartfridge/drying_rack/Process()
	. = ..()
	if(drying && dry())
		update_icon()

/obj/machinery/smartfridge/drying_rack/on_update_icon()
	ClearOverlays()
	if(inoperable())
		if(length(contents))
			icon_state = "drying_rack-plant-off"
		else
			icon_state = "drying_rack-off"
	else
		icon_state = "drying_rack"
	if(length(contents))
		icon_state = "drying_rack-plant"
		if(operable())
			icon_state = "drying_rack-close"

/obj/machinery/smartfridge/drying_rack/proc/dry()
	for(var/datum/stored_items/I in item_records)
		for(var/thing in I.instances)
			var/remove_thing = FALSE
			if(istype(thing, /obj/item/reagent_containers/food/snacks))
				var/obj/item/reagent_containers/food/snacks/S = thing
				if(S.dry || !I.get_specific_product(get_turf(src), S))
					continue
				if(S.dried_type == S.type)
					S.dry = TRUE
					S.SetName("dried [S.name]")
					S.color = "#a38463"
					stock_item(S)
					I.instances -= thing
					I.amount--
				else
					var/D = S.dried_type
					new D(get_turf(src))
					remove_thing = TRUE

			else if(istype(thing, /obj/item/stack/material))
				var/obj/item/stack/material/skin = thing
				if(!istype(skin.material, /material/skin))
					continue
				var/material/skin/skin_mat = skin.material
				if(!skin_mat.tans_to)
					continue
				var/material/leather_mat = SSmaterials.get_material_by_name(skin_mat.tans_to)
				stock_item(new leather_mat.stack_type(get_turf(src), skin.amount, skin_mat.tans_to))
				remove_thing = TRUE

			if(remove_thing)
				I.instances -= thing
				I.amount--
				qdel(thing)
				SStgui.update_uis(src)
				return TRUE
	return FALSE

/obj/machinery/smartfridge/drying_rack/tgui_act(action, list/params)
	. = ..()
	switch(action)
		if("drying")
			drying = !drying
			update_icon()

/obj/machinery/smartfridge/seeds
	name = "\improper MegaSeed Servitor"
	desc = "When you need seeds fast!"
	accepted_types = list(
		/obj/item/seeds
	)

/obj/machinery/smartfridge/secure/extract
	name = "\improper Slime Extract Storage"
	desc = "A refrigerated storage unit for slime extracts."
	icon_contents = "slime"
	req_access = list(access_research)
	accepted_types = list(
		/obj/item/slime_extract
	)

/obj/machinery/smartfridge/secure/medbay
	name = "\improper Refrigerated Medicine Storage"
	desc = "A refrigerated storage unit for storing medicine and chemicals."
	icon_contents = "chem"
	req_access = list(list(access_medical,access_chemistry))
	accepted_types = list(
		/obj/item/reagent_containers/glass,
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/ivbag
	)

/obj/machinery/smartfridge/secure/virology
	name = "\improper Refrigerated Virus Storage"
	desc = "A refrigerated storage unit for storing viral material."
	req_access = list(access_virology)
	icon_contents = "chem"
	accepted_types = list(
		/obj/item/reagent_containers/glass/beaker/vial
	)

/obj/machinery/smartfridge/chemistry
	name = "\improper Smart Chemical Storage"
	desc = "A refrigerated storage unit for medicine and chemical storage."
	icon_contents = "chem"
	accepted_types = list(
		/obj/item/storage/pill_bottle,
		/obj/item/reagent_containers
	)

/obj/machinery/smartfridge/chemistry/virology
	name = "\improper Smart Virus Storage"
	desc = "A refrigerated storage unit for volatile sample storage."


/obj/machinery/smartfridge/drinks
	name = "\improper Drink Showcase"
	desc = "A refrigerated storage unit for tasty tasty alcohol."
	icon_state = "fridge_dark"
	icon_base = "fridge_dark"
	icon_contents = "drink"
	accepted_types = list(
		/obj/item/reagent_containers/glass,
		/obj/item/reagent_containers/food/drinks,
		/obj/item/reagent_containers/food/condiment
	)

/obj/machinery/smartfridge/foods
	name = "\improper Hot Foods Display"
	desc = "A heated storage unit for piping hot meals."
	icon_state = "fridge_food"
	icon_state = "fridge_food"
	icon_contents = "food"
	accepted_types = list(
		/obj/item/reagent_containers/food/snacks,
		/obj/item/material/kitchen/utensil
	)
