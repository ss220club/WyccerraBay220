/obj/machinery/fabricator/interface_interact(mob/user)
	tgui_interact(user)
	return TRUE

/obj/machinery/fabricator/tgui_state(mob/user)
	return GLOB.default_state

/obj/machinery/fabricator/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Fabricator", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/fabricator/tgui_data(mob/user)
	var/list/data = list()
	var/functional = is_functioning()
	data["functional"] = functional
	if(functional)
		data["material_efficiency"] = mat_efficiency
		data["material_storage"] = get_material_ui_data()
		data["current_build"] = get_current_build_ui_data()
		data["build_queue"] = get_build_queue_ui_data()

	return data

/// Should go to UI_STATIC_DATA, and ONLY be updated when new fab recipe list is changed (in this case - when fab is hacked)
/obj/machinery/fabricator/tgui_static_data(mob/user)
	var/list/recipes = list()
	for(var/datum/fabricator_recipe/available_recipe as anything in SSfabrication.get_recipes(fabricator_class))
		if(available_recipe.hidden && !(fab_status_flags & FAB_HACKED))
			continue

		var/list/cost = list()
		for(var/required_resource in available_recipe.resources)
			var/list/resource = list()
			resource["name"] = stored_substances_to_names[required_resource]
			resource["amount"] = available_recipe.resources[required_resource]
			if(ispath(required_resource, /material))
				var/material/solid_material = required_resource
				resource["units_per_sheet"] = solid_material.units_per_sheet

			cost += list(resource)

		var/list/recipe = list()
		recipe["name"] = available_recipe.name
		recipe["category"] = available_recipe.category
		recipe["reference"] = "[ref(available_recipe)]"
		recipe["hidden"] = available_recipe.hidden
		recipe["cost"] = cost

		recipes += list(recipe)

	var/list/data = list()
	data["recipes"] = recipes
	data["categories"] = SSfabrication.get_categories(fabricator_class)
	return data

/obj/machinery/fabricator/tgui_act(action, list/params)
	if(..())
		return TRUE

	switch(action)
		if("make")
			return try_queue_build(locate(params["make"]), text2num(params["multiplier"]))
		if("cancel")
			return cancel_build(locate(params["cancel"]))
		if("eject_mat")
			return eject_material(params["eject_mat"])

	return FALSE


/obj/machinery/fabricator/proc/get_material_ui_data()
	PRIVATE_PROC(TRUE)

	var/list/data = list()
	for(var/material in stored_material)
		var/list/material_data = list()
		/// FABRICATOR UI TODO: add material image asset
		material_data["name"] = stored_substances_to_names[material]
		material_data["stored"] = stored_material[material]
		material_data["max"] = storage_capacity[material]

		var/is_material = ispath(material, /material)
		if(is_material)
			var/material/solid_material = material
			material_data["units_per_sheet"] = solid_material.units_per_sheet
			material_data["refundable"] = TRUE
		else
			material_data["refundable"] = FALSE

		data += list(material_data)

	return data

/obj/machinery/fabricator/proc/get_current_build_ui_data()
	PRIVATE_PROC(TRUE)

	var/list/data = list()
	if(currently_building)
		/// FABRICATOR UI TODO: add image asset for each fabricator recipe
		data["name"] = currently_building.target_recipe.name
		data["multiplier"] = currently_building.multiplier
		data["progress"] = "[Percent(currently_building.target_recipe.build_time - currently_building.remaining_time, currently_building.target_recipe.build_time, 0)]%"
	else
		data = null

	return data

/obj/machinery/fabricator/proc/get_build_queue_ui_data()
	PRIVATE_PROC(TRUE)

	var/list/data = list()
	for(var/datum/fabricator_build_order/order as anything in queued_orders)
		var/list/order_data = list()
		order_data["name"] = order.target_recipe.name
		order_data["multiplier"] = order.multiplier
		order_data["reference"] = "[ref(order)]"
		data += list(order_data)

	return data

/obj/machinery/fabricator/proc/cancel_build(datum/fabricator_build_order/order)
	if(!istype(order) || currently_building == order || !is_functioning())
		return FALSE

	if(!(order in queued_orders))
		qdel(order)
		return FALSE

	for(var/material_to_refund_path in order.earmarked_materials)
		stored_material[material_to_refund_path] = min(stored_material[material_to_refund_path] + (order.earmarked_materials[material_to_refund_path] * 0.9), storage_capacity[material_to_refund_path])

	queued_orders -= order
	qdel(order)

	return TRUE


/obj/machinery/fabricator/proc/eject_material(mat_name)
	var/material/material_to_eject = SSmaterials.get_material_by_name(mat_name)
	if(!material_to_eject)
		return FALSE

	var/stored_material_amount = stored_material[material_to_eject.type]
	if(!stored_material_amount)
		return FALSE

	/// If we have solid material - we can get it printed back
	if(istype(material_to_eject, /material))
		if(stored_material_amount < material_to_eject.units_per_sheet || !material_to_eject.stack_type)
			return FALSE

		var/sheet_count = floor(stored_material_amount / material_to_eject.units_per_sheet)
		stored_material[material_to_eject.type] -= sheet_count * material_to_eject.units_per_sheet
		material_to_eject.place_sheet(get_turf(src), sheet_count)

	/// If the material is liquid or something - we can't
	else
		stored_material[material_to_eject.type] = 0

	return TRUE
