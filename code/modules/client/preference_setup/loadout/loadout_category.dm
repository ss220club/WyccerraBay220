/datum/gear_category
	/// Name of the category. Used for sorting
	var/category_name = ""
	/// Assoc list of gear instances as
	VAR_PRIVATE/list/gear_items = list()

/datum/gear_category/New(category_name)
	src.category_name = category_name

/datum/gear_category/proc/add_gear(datum/gear/gear_to_add)
	ASSERT(istype(gear_to_add))
	gear_items[gear_to_add.display_name] = gear_to_add

/datum/gear_category/proc/sort_gear()
	gear_items = sortAssoc(gear_items)

/// Returns copy of gear `gear_items`
/datum/gear_category/proc/get_gear_items()
	if(!gear_items)
		stack_trace("`gear_items` should not be null")
		gear_items = list()

	return gear_items.Copy()
