/datum/world_topic_handler/status
	topic_key = "status"

/datum/world_topic_handler/status/execute(list/input, key_valid)
	var/list/status_info = list()
	status_info["version"] = "NoVersion"
	status_info["mode"] = Master.current_runlevel
	status_info["respawn"] = FALSE
	status_info["enter"] = config.enter_allowed
	status_info["ai"] = TRUE
	status_info["host"] = world.host ? world.host : null
	status_info["players"] = list()
	status_info["roundtime"] = roundduration2text()
	status_info["stationtime"] = stationtime2text()
	status_info["oldstationtime"] = stationtime2text()
	status_info["listed"] = "Public"
	if(!world.hub_password)
		status_info["listed"] = "Invisible"
	var/player_count = 0
	var/admin_count = 0

	for(var/client/C in GLOB.clients)
		if(C.holder)
			admin_count++
		player_count++
	status_info["players"] = player_count
	status_info["admins"] = admin_count
	status_info["map_name"] = "Sierra"
	status_info["round_id"] = game_id

	// Export performance metrics
	status_info["perfmetrics"] = list(
		"td" = list(
			"time_dilation_current" = Master.tickdrift,
			"time_dilation_avg_fast" = 0,
			"time_dilation_avg" = 0,
			"time_dilation_avg_slow" = 0
		),
		"mcpu" = world.map_cpu,
		"cpu" = world.cpu
	)


	// Add more info if we are authed
	if(key_valid)
		if(SSticker.mode)
			status_info["real_mode"] = SSticker.mode.name
			status_info["security_level"] = ""
			status_info["ticker_state"] = 1

		if(SSshuttle.emergency)
			// Shuttle status, see /__DEFINES/stat.dm
			status_info["shuttle_mode"] = 0
			// Shuttle timer, in seconds
			status_info["shuttle_timer"] = 0

	return json_encode(status_info)
