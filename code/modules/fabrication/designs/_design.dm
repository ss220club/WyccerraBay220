/singleton/fabricator_recipe
	abstract_type = /singleton/fabricator_recipe
	/// Name of recipe. Used for UI etc.
	var/name
	/// Id of the recipe. Used for faster lookup for recipe in SSfabrication and for image of recipe on UI
	var/id
	/// Should fabracator be hacked to access this recipe or not
	var/hidden = FALSE
	/// Category this recipe has
	var/category = "General"
	/// Result of this recipe
	var/obj/item/path
	/// Image of this recipe for UIs. Base64.
	var/image
	/// Base time spent to produce item by this recipe
	var/build_time = 5 SECONDS
	/// Resources required for this recipe
	var/list/resources
	///
	var/list/fabricator_types = list(
		FABRICATOR_CLASS_GENERAL
	)
	var/list/ignore_materials = list(
		/material/waste = TRUE
	)

// Populate name and resources from the product type.
/singleton/fabricator_recipe/Initialize()
	. = ..()
	if(!id)
		stack_trace("Fabricator recipe without id: [log_info_line(src)]")
		return

	if(!path)
		stack_trace("Fabricator recipe without result path: [log_info_line(src)]")
		return

	if(!name)
		name = initial(path.name)

	if(!resources)
		resources = list()

	var/obj/item/item_prototype = new path
	if(length(item_prototype.matter))
		for(var/material in item_prototype.matter)
			var/material/M = SSmaterials.get_material_by_name(material)
			if(istype(M) && !ignore_materials[M.type])
				resources[M.type] = item_prototype.matter[material] * FABRICATOR_EXTRA_COST_FACTOR

	if(item_prototype.reagents && length(item_prototype.reagents.reagent_list))
		for(var/datum/reagent/R in item_prototype.reagents.reagent_list)
			resources[R.type] = R.volume * FABRICATOR_EXTRA_COST_FACTOR

	item_prototype.ImmediateOverlayUpdate()
	image = icon2base64(getFlatIcon(item_prototype))

	qdel(item_prototype)
