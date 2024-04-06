/datum/world_topic_handler/adminwho
	topic_key = "adminwho"
	requires_commskey = TRUE

/datum/world_topic_handler/adminwho/execute(list/input, key_valid)
	var/list/out_data = list()

	for(var/client/C in GLOB.admins)
		var/list/this_entry = list()
		// Send both incase we want special formatting
		this_entry["ckey"] = C.ckey
		this_entry["key"] = C.key
		this_entry["rank"] = C.holder.rank
		// is_afk() returns an int of inactivity, we can use this to determine AFK for how long
		// This info will not be shown in public channels
		this_entry["afk"] = C.is_afk()

		out_data += list(this_entry)

	return json_encode(out_data)
