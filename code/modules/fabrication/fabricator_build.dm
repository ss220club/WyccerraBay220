/obj/machinery/fabricator/proc/update_current_build(spend_time)

	if(!istype(currently_building) || !is_functioning())
		return

	// Decrement our current build timer.
	currently_building.remaining_time -= max(1, max(1, spend_time * build_time_multiplier))
	if(currently_building.remaining_time <= 0)
		// Print the item.
		if(ispath(currently_building.target_recipe.path, /obj/item/stack))
			new currently_building.target_recipe.path(get_turf(src), amount = currently_building.multiplier)
		else
			new currently_building.target_recipe.path(get_turf(src))

		QDEL_NULL(currently_building)
		get_next_build()
		update_icon()

	SStgui.update_uis(src)

/obj/machinery/fabricator/proc/get_next_build()
	PRIVATE_PROC(TRUE)

	currently_building = null
	if(length(queued_orders))
		currently_building = queued_orders[1]
		queued_orders -= currently_building
		start_building()
	else
		stop_building()

/obj/machinery/fabricator/proc/start_building()
	PRIVATE_PROC(TRUE)

	if(!(fab_status_flags & FAB_BUSY) && is_functioning())
		fab_status_flags |= FAB_BUSY
		update_use_power(POWER_USE_ACTIVE)
		update_icon()

/obj/machinery/fabricator/proc/stop_building()
	PRIVATE_PROC(TRUE)

	if(fab_status_flags & FAB_BUSY)
		fab_status_flags &= ~FAB_BUSY
		update_use_power(POWER_USE_IDLE)
		update_icon()

/obj/machinery/fabricator/proc/try_queue_build(singleton/fabricator_recipe/recipe, multiplier)
	// Do some basic sanity checking.
	if(!is_functioning() || !istype(recipe) || !(fabricator_class in recipe.fabricator_types))
		return FALSE

	multiplier = sanitize_integer(multiplier, 1, 100, 1)
	if(!ispath(recipe.path, /obj/item/stack) && multiplier > 1)
		multiplier = 1

	// Check if sufficient resources exist.
	for(var/material in recipe.resources)
		if(stored_material[material] < round(recipe.resources[material] * mat_efficiency) * multiplier)
			return FALSE

	// Generate and track a new order.
	var/datum/fabricator_build_order/order = new
	order.remaining_time = recipe.build_time
	order.target_recipe = recipe
	order.multiplier = multiplier
	queued_orders += order

	// Remove/earmark resources.
	for(var/material in recipe.resources)
		var/removed_mat = round(recipe.resources[material] * mat_efficiency) * multiplier
		stored_material[material] = max(0, stored_material[material] - removed_mat)
		order.earmarked_materials[material] = removed_mat

	if(!currently_building)
		get_next_build()
	else
		start_building()

	return TRUE
