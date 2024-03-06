/datum/stored_items
	// Name of the item(s) displayed
	var/item_name = "name"
	/// Path of the item
	var/atom/item_path = null
	var/atom/storing_object
	/// The original amount held
	var/amount = 0
	/// What items are actually stored
	var/list/instances

/datum/stored_items/New(atom/storing_object, atom/path, name = null, amount = 0)
	if(!istype(storing_object))
		CRASH("Unexpected storing object.")

	src.storing_object = storing_object
	src.item_path = path
	src.amount = amount
	src.item_name = name

	if(!name)
		src.item_name = initial(path.name)
	else
		src.item_name = name

	..()

/datum/stored_items/Destroy()
	storing_object = null
	QDEL_NULL_LIST(instances)
	. = ..()

/datum/stored_items/dd_SortValue()
	return item_name

/datum/stored_items/proc/get_amount()
	return amount

/datum/stored_items/proc/add_product(atom/movable/product)
	if(product.type != item_path)
		return FALSE
	if(product in instances)
		return FALSE
	product.forceMove(storing_object)
	LAZYADD(instances, product)
	amount++
	return TRUE

/datum/stored_items/proc/get_product(product_location)
	if(!get_amount() || !product_location)
		return

	var/atom/movable/product
	if(LAZYLEN(instances))
		product = instances[length(instances)]	// Remove the last added product
		LAZYREMOVE(instances, product)
	else
		product = new item_path(storing_object)

	amount--
	product.forceMove(product_location)
	return product

/datum/stored_items/proc/get_specific_product(product_location, atom/movable/product)
	if(!get_amount() || !instances || !product_location || !product)
		return FALSE

	. = instances.Remove(product)
	if(.)
		product.forceMove(product_location)

/datum/stored_items/proc/merge(datum/stored_items/other)
	if(other.item_path != item_path)
		return FALSE
	for(var/atom/movable/thing in other.instances)
		other.instances -= thing
		if(thing in instances)
			amount-- // Don't double-count
		else
			thing.forceMove(storing_object)
			LAZYADD(instances, thing)
	amount += other.amount
	qdel(other)
	return TRUE

/datum/stored_items/proc/migrate(atom/new_storing_obj)
	storing_object = new_storing_obj
	for(var/atom/movable/thing in instances)
		thing.forceMove(new_storing_obj)
