#define WHITELISTFILE "data/whitelist.txt"
#define ALIEN_WHITELIST_FILE "config/alienwhitelist.json"

var/global/list/whitelist = list()

/hook/startup/proc/loadWhitelist()
	if(config.usewhitelist)
		load_whitelist()

	return TRUE

/proc/load_whitelist()
	whitelist = file2list(WHITELISTFILE)
	if(!length(whitelist))
		whitelist = null

/proc/check_whitelist(mob/M)
	if(!whitelist)
		return FALSE
	return ("[M.ckey]" in whitelist)

var/global/list/alien_whitelist = list()

/hook/startup/proc/loadAlienWhitelist()
	if(!config.usealienwhitelist)
		return TRUE

	if(load_alienwhitelistSQL())
		return TRUE

	to_world_log("Could not load alienwhitelist via SQL. Reverting to legacy approach (JSON file)")

	return load_alienwhitelist()

/proc/load_alienwhitelist()
	var/text = file2text(ALIEN_WHITELIST_FILE)
	if (!text)
		log_misc("Failed to load [ALIEN_WHITELIST_FILE]")
		return FALSE

	var/list/ckey_to_whitelisted_races = json_decode(text)
	for(var/ckey in ckey_to_whitelisted_races)
		var/list/whitelisted_races = ckey_to_whitelisted_races[ckey]
		for(var/race in whitelisted_races)
			if(islist(alien_whitelist[ckey]))
				alien_whitelist[ckey][race] = TRUE
			else
				alien_whitelist[ckey] = list(race = TRUE)

	return TRUE

/proc/load_alienwhitelistSQL()
	var/DBQuery/query = dbcon_old.NewQuery("SELECT * FROM whitelist")
	if(!query.Execute())
		to_world_log(dbcon_old.ErrorMsg())
		return FALSE

	while(query.NextRow())
		var/list/row = query.GetRowData()

		var/ckey = row["ckey"]
		var/race = row["race"]
		if(islist(alien_whitelist[ckey]))
			alien_whitelist[ckey][race] = TRUE
		else
			alien_whitelist[ckey] = list(race = TRUE)

	return TRUE

/proc/is_any_alien_whitelisted(mob/mob_to_check, list/species)
	if(!mob_to_check || !species)
		return FALSE

	if (GLOB.skip_allow_lists)
		return TRUE

	if(!config.usealienwhitelist)
		return TRUE

	if(check_rights(R_ADMIN, 0, mob_to_check))
		return TRUE

	if(!islist(species))
		species = list(species)


	for(var/single_species in species)
		if(istype(single_species, /datum/language))
			var/datum/language/language_to_check = single_species
			if(!(language_to_check.flags & (WHITELISTED|RESTRICTED)))
				return TRUE

			return whitelist_lookup(language_to_check.name, mob_to_check.ckey)

		if(istype(single_species, /datum/species))
			var/datum/species/species_to_check = single_species
			if(!(species_to_check.spawn_flags & (SPECIES_IS_WHITELISTED|SPECIES_IS_RESTRICTED)))
				return TRUE

			return whitelist_lookup(species_to_check.get_bodytype(species_to_check), mob_to_check.ckey)

	return FALSE

/proc/whitelist_lookup(item, ckey)
	if(!config.usealienwhitelist)
		return TRUE
	return alien_whitelist?[ckey]?[lowertext(item)]

#undef WHITELISTFILE
