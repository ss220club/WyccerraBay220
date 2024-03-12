SUBSYSTEM_DEF(fabrication)
	name = "Fabrication"
	flags = SS_NO_FIRE
	init_order = SS_INIT_MISC_LATE

	/**
	 * Assoc list of ("fabricator_type" => (Set of subtypes of `/singleton/fabricator_recipe`) ). Set during `Initialize()`.
	 *
	 * Example formatting:
	 * ```dm
	 * 	list(
	 * 		"general" = list(
	 * 			/singleton/fabricator_recipe/A,
	 * 			/singleton/fabricator_recipe/B
	 * 		),
	 * 		"microlathe" = list(
	 * 			/singleton/fabricator_recipe/C,
	 * 			/singleton/fabricator_recipe/D
	 * 		)
	 * 	)
	 * ```
	 */
	var/static/list/recipes = list()

	/**
	 * Assoc list of ("fabricator_type" => "categories_available"). Global list of recipe categories. These are pulled from the recipes provided in `recipes`. Set during `Initialize()`.
	 *
	 * Example formatting:
	 * ```dm
	 * 	list(
	 * 		"general" = list(
	 * 			"Arms and Ammunition",
	 * 			"Devices and Components"
	 * 		),
	 * 		"microlathe" = list(
	 * 			"Cutlery",
	 * 			"Drinking Glasses"
	 * 		)
	 * 	)
	 * ```
	 */
	var/static/list/categories = list()

	/**
	 * List of lists (Paths (`/obj/item`) => Paths (`/singleton/crafting_stage`)). Global list of crafting stages. These are pulled from each crafting stage's `begins_with_object_type` var. Set during `Initialize()`.
	 */
	var/static/list/stages_by_type = list()


/datum/controller/subsystem/fabrication/UpdateStat(time)
	return


/datum/controller/subsystem/fabrication/Initialize(start_uptime)
	var/list/recipes_map = GET_SINGLETON_SUBTYPE_MAP(/singleton/fabricator_recipe)
	for(var/recipe_type in recipes_map)
		var/singleton/fabricator_recipe/recipe = recipes_map[recipe_type]
		if(!recipe.name)
			continue

		for(var/fabricator_type in recipe.fabricator_types)
			LAZYADDASSOCLIST(recipes, fabricator_type, recipe)
			LAZYORASSOCLIST(categories, fabricator_type, recipe.category)

	var/list/stages = GET_SINGLETON_SUBTYPE_MAP(/singleton/crafting_stage)
	for (var/id in stages)
		var/singleton/crafting_stage/stage = stages[id]
		var/stage_begins_with_type = stage.begins_with_object_type
		if (!ispath(type))
			continue

		LAZYORASSOCLIST(stages_by_type, stage_begins_with_type, stage)

/**
 * Retrieves a list of categories for the given root type.
 *
 * **Parameters**:
 * - `type` - The root type to fetch from the `categories` list.
 *
 * Returns list of strings. The categories associated with the given root type.
 */
/datum/controller/subsystem/fabrication/proc/get_categories(fabricator_type)
	return categories[fabricator_type]


/**
 * Retrieves a list of recipes for the given root type.
 *
 * **Parameters**:
 * - `type` - The root type to fetch from the `recipes` list.
 *
 * Returns list of paths (`/singleton/fabricator_recipe`). The recipes associated with the given root type.
 */
/datum/controller/subsystem/fabrication/proc/get_recipes(fabricator_type)
	return recipes[fabricator_type]


/**
 * Retrieves a list of crafting stages for the given type path.
 *
 * **Parameters**:
 * - `type` - The object type path to fetch from the `stages_by_type` list.
 *
 * Returns list of paths (`/singleton/crafting_stage`). The initial crafting stages with the given type set as their `begins_with_object_type`.
 */
/datum/controller/subsystem/fabrication/proc/find_crafting_recipes(begins_with_object_type)
	if (isnull(stages_by_type[begins_with_object_type]))
		stages_by_type[begins_with_object_type] = FALSE
		for (var/match in stages_by_type)
			if (ispath(begins_with_object_type, match))
				stages_by_type[begins_with_object_type] = stages_by_type[match]
				break

	return stages_by_type[begins_with_object_type]


/**
 * Attempts to start a crafting stage using the target and tool.
 *
 * **Parameters**:
 * - `target` - The target object. This will be compared with `begins_with_object_type` from crafting stages.
 * - `tool` - The item being used. This will be compared with `completion_trigger_type` from crafting stages.
 * - `user` - The mob performing the interaction.
 *
 * Has no return value.
 */
/datum/controller/subsystem/fabrication/proc/try_craft_with(obj/item/target, obj/item/tool, mob/user)
	var/turf/turf = get_turf(target)
	if (!turf)
		return

	var/list/stages = SSfabrication.find_crafting_recipes(target.type)
	for (var/singleton/crafting_stage/stage in stages)
		if (stage.can_begin_with(target) && stage.is_appropriate_tool(tool, user))
			var/obj/item/crafting_holder/crafting = new (turf, stage, target, tool, user)
			if (stage.progress_to(tool, user, crafting))
				return crafting
			qdel(crafting)
