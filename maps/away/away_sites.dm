// Hey! Listen! Update \config\away_site_blacklist.txt with your new ruins!

/datum/map_template/ruin/away_site
	var/list/generate_mining_by_z
	prefix = "maps/away/"
	skip_main_unit_tests = "Is an away site."

/datum/map_template/ruin/away_site/after_load(z)
	if(!generate_mining_by_z)
		return

	if(!islist(generate_mining_by_z))
		generate_mining_by_z = list(generate_mining_by_z)

	for(var/target_z_level in generate_mining_by_z)
		var/current_z = z + target_z_level - 1
		new /datum/random_map/automata/cave_system(null, 1, 1, current_z, world.maxx, world.maxy)
		new /datum/random_map/noise/ore(null, 1, 1, current_z, world.maxx, world.maxy)
		GLOB.using_map.refresh_mining_turfs(current_z)
