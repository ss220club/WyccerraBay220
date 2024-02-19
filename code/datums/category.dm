/**********************
* Category Collection *
**********************/
/datum/category_collection
	/// Type of categories to initialize
	var/category_group_type
	/// Lazy list of initialized categories
	var/list/datum/category_group/categories
	/// Lazy associative list of initialized categories, keyed by name
	var/list/datum/category_group/categories_by_name

/datum/category_collection/New()
	..()

	for(var/datum/category_group/category_type as anything in typesof(category_group_type))
		if(!initial(category_type.name))
			continue

		var/datum/category_group/category = new category_type(src)
		LAZYADD(categories, category)
		LAZYADDASSOC(categories_by_name, category.name, category)

	if(LAZYLEN(categories))
		categories = dd_sortedObjectList(categories)

/datum/category_collection/Destroy()
	QDEL_NULL_LIST(categories)
	LAZYCLEARLIST(categories_by_name)
	return ..()

/******************
* Category Groups *
******************/
/datum/category_group
	var/name = ""
	var/category_item_type                      // Type of items to initialize
	var/list/datum/category_item/items          // List of initialized items
	var/list/datum/category_item/items_by_name  // Associative list of initialized items, by name
	var/datum/category_collection/collection    // The collection this group belongs to

/datum/category_group/New(datum/category_collection/cc)
	..()
	collection = cc
	for(var/datum/category_item/item_type as anything in typesof(category_item_type))
		if(!initial(item_type.name))
			continue

		var/datum/category_item/item = new item_type(src)
		LAZYADD(items, item)
		LAZYADDASSOC(items_by_name, item.name, item)

	// For whatever reason dd_insertObjectList(items, item) doesn't insert in the correct order
	// If you change this, confirm that character setup doesn't become completely unordered.
	if(LAZYLEN(items))
		items = dd_sortedObjectList(items)

/datum/category_group/Destroy()
	QDEL_NULL_LIST(items)
	collection = null
	return ..()

/datum/category_group/dd_SortValue()
	return name


/*****************
* Category Items *
*****************/
/datum/category_item
	var/name = ""
	var/datum/category_group/category		// The group this item belongs to

/datum/category_item/New(datum/category_group/cg)
	..()
	category = cg

/datum/category_item/Destroy()
	category = null
	return ..()

/datum/category_item/dd_SortValue()
	return name
