SUBSYSTEM_DEF(init_misc_late)
	name = "Misc Initialization (Late)"
	init_order = SS_INIT_MISC_LATE
	flags = SS_NO_FIRE


/datum/controller/subsystem/init_misc_late/UpdateStat(time)
	if (initialized)
		return
	..()


/datum/controller/subsystem/init_misc_late/Initialize(start_uptime)
	GLOB.using_map.build_away_sites()
	GLOB.using_map.build_exoplanets()
	init_recipes()
	init_xenoarch()

GLOBAL_VAR_INIT(microwave_maximum_item_storage, 0)
GLOBAL_LIST_EMPTY(microwave_recipes)
GLOBAL_LIST_EMPTY(microwave_accepts_reagents)
GLOBAL_LIST_EMPTY(microwave_accepts_items)

/datum/controller/subsystem/init_misc_late/proc/init_recipes()
	var/list/reagents = list()
	var/list/items = list(
		/obj/item/holder = TRUE,
		/obj/item/reagent_containers/food/snacks/grown = TRUE
	)
	for (var/datum/microwave_recipe/recipe as anything in subtypesof(/datum/microwave_recipe))
		recipe = new recipe
		recipe.produce_amount = 0
		for (var/tag in recipe.required_produce)
			recipe.produce_amount += recipe.required_produce[tag]
		var/objects_amount = recipe.produce_amount + length(recipe.required_items)
		recipe.weight = objects_amount + length(recipe.required_reagents)
		if (!recipe.result_path || !recipe.weight)
			log_error("Recipe [recipe.type] has invalid results or requirements.")
			continue
		GLOB.microwave_recipes += recipe
		for (var/type in recipe.required_reagents)
			reagents[type] = TRUE
		for (var/type in recipe.required_items)
			items[type] = TRUE
		GLOB.microwave_maximum_item_storage = max(GLOB.microwave_maximum_item_storage, objects_amount)
	for (var/type in reagents)
		GLOB.microwave_accepts_reagents += type
	for (var/type in items)
		GLOB.microwave_accepts_items += type
	sortTim(GLOB.microwave_recipes, GLOBAL_PROC_REF(cmp_microwave_recipes_by_weight_dsc))

/proc/cmp_microwave_recipes_by_weight_dsc(datum/microwave_recipe/a, datum/microwave_recipe/b)
	return a.weight - b.weight


GLOBAL_LIST_EMPTY(xeno_artifact_turfs)
GLOBAL_LIST_EMPTY(xeno_digsite_turfs)

/datum/controller/subsystem/init_misc_late/proc/init_xenoarch()
	var/list/site_turfs = list()
	var/list/artifact_turfs = list()
	var/datum/map/map = GLOB.using_map
	if (!map)
		GLOB.xeno_artifact_turfs = list()
		GLOB.xeno_digsite_turfs = list()
		return

	var/static/excavation_turf_chance = 0.5
	var/static/minimal_distance_between_turfs = 3
	var/list/banned_levels = map.admin_levels + map.escape_levels
	for(var/z_level_index in 1 to world.maxz)
		if(z_level_index in banned_levels)
			continue

		var/list/mining_turfs = mining_walls["[z_level_index]"]
		if(!length(mining_turfs))
			continue

		for(var/turf/simulated/mineral/mineral_turf as anything in mining_turfs)
			if (!mineral_turf.density)
				continue

			if (!mineral_turf.geologic_data)
				mineral_turf.geologic_data = new(mineral_turf)

			var/has_space = TRUE
			for(var/turf/site_turf as anything in site_turfs)
				var/distance_between_turfs = get_dist_euclidian(site_turf, mineral_turf)
				if(distance_between_turfs > 3)
					continue

				has_space = FALSE
				break

			if(!has_space)
				continue

			site_turfs += mineral_turf

			var/list/possible_site_turfs = list()
			for(var/turf/simulated/mineral/T in RANGE_TURFS(mineral_turf, 2))
				if(!T.density)
					continue

				if(T.finds)
					continue

				possible_site_turfs += T

			possible_site_turfs = shuffle(possible_site_turfs)
			LIST_RESIZE(possible_site_turfs, min(rand(4, 12), length(possible_site_turfs)))

			var/site_type = get_random_digsite_type()
			for(var/turf/simulated/mineral/T as anything in possible_site_turfs)
				if(!T.finds)
					var/list/finds = list()
					if (prob(50))
						finds += new /datum/find (site_type, rand(10, 190))
					else if (prob(75))
						finds += new /datum/find (site_type, rand(10, 90))
						finds += new /datum/find (site_type, rand(110, 190))
					else
						finds += new /datum/find (site_type, rand(10, 50))
						finds += new /datum/find (site_type, rand(60, 140))
						finds += new /datum/find (site_type, rand(150, 190))
					var/datum/find/F = finds[1]
					if (F.excavation_required <= F.view_range)
						T.archaeo_overlay = "overlay_archaeo[rand(1, 3)]"
						T.update_icon()
					T.finds = finds

				if(site_type == DIGSITE_GARDEN)
					continue

				if(site_type == DIGSITE_ANIMAL)
					continue

				artifact_turfs += T

			CHECK_TICK

	GLOB.xeno_digsite_turfs = site_turfs
	GLOB.xeno_artifact_turfs = list()

	var/xeno_artifact_turfs_amount = min(rand(6, 12), length(artifact_turfs))
	for (var/i = 1 to xeno_artifact_turfs_amount)
		var/turf/simulated/mineral/selected_mineral = pick_n_take(artifact_turfs)
		// Failsafe for invalid turf types
		if (!istype(selected_mineral))
			continue

		GLOB.xeno_artifact_turfs += selected_mineral
		selected_mineral.artifact_find = new
