#define PRINT_MULTIPLIER_DIVISOR 5

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

	data["category"] =   show_category
	data["functional"] = is_functioning()

	if(is_functioning())
		var/current_storage =  list()
		data["material_storage"] =  current_storage
		for(var/material in stored_material)
			var/list/material_data = list()
			var/mat_name = capitalize(stored_substances_to_names[material])
			material_data["name"] =        mat_name
			material_data["stored"] =      stored_material[material]
			material_data["max"] =         storage_capacity[material]
			material_data["eject_key"] = stored_substances_to_names[material]
			material_data["eject_label"] =   ispath(material, /material) ? "Eject" : "Flush"
			data["material_storage"] += list(material_data)

		var/list/current_build = list()
		data["current_build"] = current_build
		if(currently_building)
			current_build["name"] =       currently_building.target_recipe.name
			current_build["multiplier"] = currently_building.multiplier
			current_build["progress"] =   "[100-round((currently_building.remaining_time/currently_building.target_recipe.build_time)*100)]%"
		else
			current_build["name"] =       "Nothing."
			current_build["multiplier"] = "-"
			current_build["progress"] =   "-"

		data["build_queue"] = list()
		if(length(queued_orders))
			for(var/datum/fabricator_build_order/order in queued_orders)
				var/list/order_data = list()
				order_data["name"] = order.target_recipe.name
				order_data["multiplier"] = order.multiplier
				order_data["reference"] = "\ref[order]"
				data["build_queue"] += list(order_data)
		else
			var/list/order_data = list()
			order_data["name"] = "Nothing."
			order_data["multiplier"] = "-"
			data["build_queue"] += list(order_data)

		data["build_options"] = list()
		for(var/datum/fabricator_recipe/R in SSfabrication.get_recipes(fabricator_class))
			if(R.hidden && !(fab_status_flags & FAB_HACKED) || (show_category != "All" && show_category != R.category))
				continue
			var/list/build_option = list()
			var/max_sheets = 0
			build_option["name"] =      R.name
			build_option["reference"] = "\ref[R]"
			build_option["illegal"] =   R.hidden
			if(!length(R.resources))
				build_option["cost"] = "No resources required."
				max_sheets = 100
			else
				//Make sure it's buildable and list required resources.
				var/list/material_components = list()
				for(var/material in R.resources)
					var/sheets = round(stored_material[material]/round(R.resources[material]*mat_efficiency))
					if(isnull(max_sheets) || max_sheets > sheets)
						max_sheets = sheets
					if(stored_material[material] < round(R.resources[material]*mat_efficiency))
						build_option["unavailable"] = 1
					material_components += "[round(R.resources[material] * mat_efficiency)] [stored_substances_to_names[material]]"
				build_option["cost"] = "[capitalize(jointext(material_components, ", "))]."
			if(ispath(R.path, /obj/item/stack) && max_sheets >= PRINT_MULTIPLIER_DIVISOR)
				var/obj/item/stack/R_stack = R.path
				build_option["multipliers"] = list()
				for(var/i = 1 to floor(min(R_stack.max_amount, max_sheets)/PRINT_MULTIPLIER_DIVISOR))
					var/mult = i * PRINT_MULTIPLIER_DIVISOR
					build_option["multipliers"] += list(list("label" = "x[mult]", "multiplier" = mult))
			data["build_options"] += list(build_option)
	return data

/obj/machinery/fabricator/tgui_act(action, list/params)
	if(..())
		return
	. = TRUE
	switch(action)
		if(change_category)
			var/choice = input("Which category do you wish to display?") as null|anything in SSfabrication.get_categories(fabricator_class)|"All"
			if(!choice || !CanUseTopic(user, state))
				return FALSE
			show_category = choice
			return TRUE
		if("make")
			try_queue_build(locate(params["make"]), text2num(params["multiplier"]))
			return TRUE
		if("cancel")
			try_cancel_build(locate(params["cancel"]))
			return TRUE
		if("eject_mat")
			try_dump_material(params["eject_mat"])
			return TRUE

/obj/machinery/fabricator/proc/try_cancel_build(datum/fabricator_build_order/order)
	if(!istype(order) && !currently_building = order && !is_functioning())
		return
	if(!order in queued_orders)
		return
	for(var/mat in order.earmarked_materials)
		stored_material[mat] = min(stored_material[mat] + (order.earmarked_materials[mat] * 0.9), storage_capacity[mat])
	queued_orders -= order
	qdel(order)

/obj/machinery/fabricator/proc/try_dump_material(mat_name)
	for(var/mat_path in stored_substances_to_names)
		if(stored_substances_to_names[mat_path] != mat_name)
			return
		if(ispath(mat_path, /material))
			var/material/mat = SSmaterials.get_material_by_name(mat_name)
			if(mat && stored_material[mat_path] > mat.units_per_sheet && mat.stack_type)
				var/sheet_count = floor(stored_material[mat_path]/mat.units_per_sheet)
				stored_material[mat_path] -= sheet_count * mat.units_per_sheet
				mat.place_sheet(get_turf(src), sheet_count)
		else if(!isnull(stored_material[mat_path]))
			stored_material[mat_path] = 0

#undef PRINT_MULTIPLIER_DIVISOR
