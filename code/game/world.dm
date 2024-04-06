#define RECOMMENDED_VERSION 514
#define FAILED_DB_CONNECTION_CUTOFF 5
#define THROTTLE_MAX_BURST 15 SECONDS
#define SET_THROTTLE(TIME, REASON) throttle[1] = base_throttle + (TIME); throttle[2] = (REASON);



var/global/game_id = randhex(8)

GLOBAL_VAR(href_logfile)


// Find mobs matching a given string
//
// search_string: the string to search for, in params format; for example, "some_key;mob_name"
// restrict_type: A mob type to restrict the search to, or null to not restrict
//
// Partial matches will be found, but exact matches will be preferred by the search
//
// Returns: A possibly-empty list of the strongest matches
/proc/text_find_mobs(search_string, restrict_type = null)
	var/list/search = params2list(search_string)
	var/list/ckeysearch = list()
	for(var/text in search)
		ckeysearch += ckey(text)

	var/list/match = list()

	for(var/mob/M in SSmobs.mob_list)
		if(restrict_type && !istype(M, restrict_type))
			continue
		var/strings = list(M.name, M.ckey)
		if(M.mind)
			strings += M.mind.assigned_role
			strings += M.mind.special_role
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species)
				strings += H.species.name
		for(var/text in strings)
			if(ckey(text) in ckeysearch)
				match[M] += 10 // an exact match is far better than a partial one
			else
				for(var/searchstr in search)
					if(findtext(text, searchstr))
						match[M] += 1

	var/maxstrength = 0
	for(var/mob/M in match)
		maxstrength = max(match[M], maxstrength)
	for(var/mob/M in match)
		if(match[M] < maxstrength)
			match -= M

	return match


/proc/stack_trace(msg)
	CRASH(msg)

/proc/enable_debugging(mode, port)
	CRASH("auxtools not loaded")


/proc/auxtools_expr_stub()
	return


#ifndef UNIT_TEST
/hook/startup/proc/set_visibility()
	world.update_hub_visibility(config.hub_visible)
	return TRUE
#endif

/world/New()
	TgsNew(new /datum/tgs_event_handler/impl, TGS_SECURITY_TRUSTED)
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		CALL_EXT(debug_server, "auxtools_init")()
		enable_debugging()

	SetupLogs()
	var/date_string = time2text(world.realtime, "YYYY/MM/DD")
	rustg_log_write_formatted("[GLOB.log_directory]/game.log", "Starting up. (ID: [game_id])")
	rustg_log_write_formatted("[GLOB.log_directory]/game.log", "---------------------------")


	if (config)
		if (config.server_name)
			name = "[config.server_name]"
		if (config.log_runtime)
			log = "data/logs/runtime/[date_string]_[time2text(world.timeofday, "hh:mm")]_[game_id].log"
			to_world_log("Game [game_id] starting up at [time2text(world.timeofday, "hh:mm.ss")]")
		if (config.log_hrefs)
			GLOB.href_logfile = file("data/logs/[date_string] hrefs.htm")

	if (byond_version < RECOMMENDED_VERSION)
		to_world_log("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")
	callHook("startup")
	QDEL_NULL(__global_init)
	..()

#ifdef UNIT_TEST
	log_unit_test("Unit Tests Enabled. This will destroy the world when testing is complete.")
	load_unit_test_changes()
#endif
	Master.Initialize(10, FALSE, TRUE)

/world/Del()
	var/debug_server = world.GetConfig("env", "AUXTOOLS_DEBUG_DLL")
	if (debug_server)
		CALL_EXT(debug_server, "auxtools_shutdown")()
	callHook("shutdown")
	return ..()


GLOBAL_LIST_EMPTY(world_topic_throttle)
GLOBAL_VAR_INIT(world_topic_last, world.timeofday)


/world/Topic(T, addr, master, key)
	TGS_TOPIC
	log_misc("WORLD/TOPIC: \"[T]\", from:[addr], master:[master], key:[key]")

	// Handle spam prevention, if their IP isnt in the whitelist
	if(!(addr in GLOB.configuration.system.topic_ip_ratelimit_bypass))
		if(!GLOB.world_topic_spam_prevention_handlers[addr])
			GLOB.world_topic_spam_prevention_handlers[addr] = new /datum/world_topic_spam_prevention_handler(addr)

		var/datum/world_topic_spam_prevention_handler/sph = GLOB.world_topic_spam_prevention_handlers[addr]

		// Lock the user out and cancel their topic if needed
		if(sph.check_lockout())
			return

	var/list/input = params2list(T)

	var/datum/world_topic_handler/wth

	for(var/H in GLOB.world_topic_handlers)
		if(H in input)
			wth = GLOB.world_topic_handlers[H]
			break

	if(!wth)
		return

	// If we are here, the handler exists, so it needs to be invoked
	wth = new wth()
	return wth.invoke(input)


/world/Reboot(reason)
	Master.Shutdown()

	for(var/thing in GLOB.clients)
		if(!thing)
			continue
		var/client/C = thing
		C?.tgui_panel?.send_roundrestart()
		if(config.server) //if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			send_link(C, "byond://[config.server]")

	rustg_log_close_all()
	if(config.wait_for_sigusr1_reboot && reason != 3)
		text2file("foo", "reboot_called")
		to_world(SPAN_DANGER("World reboot waiting for external scripts. Please be patient."))
		return

	// [SIERRA-ADD]
	if(config.shutdown_on_reboot)
		sleep(0)
		del(world)
		TgsEndProcess()
		return
	// [/SIERRA-ADD]
	TgsReboot()
	..(reason)

/hook/startup/proc/loadMode()
	world.load_mode()
	return TRUE

/world/proc/load_mode()
	if(!fexists("data/mode.txt"))
		return

	var/list/Lines = file2list("data/mode.txt")
	if(length(Lines))
		if(Lines[1])
			SSticker.master_mode = Lines[1]
			log_misc("Saved mode is '[SSticker.master_mode]'")

/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	to_file(F, the_mode)


/world/proc/update_status()
	if (!config?.hub_visible || !config.hub_entry)
		return
	status = config.generate_hub_entry()


/world/proc/SetupLogs()
	GLOB.log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM/DD")]/round-"
	if(game_id)
		GLOB.log_directory += "[game_id]"
	else
		GLOB.log_directory += "[replacetext(time_stamp(), ":", ".")]"


var/global/failed_db_connections = 0
var/global/failed_old_db_connections = 0

/hook/startup/proc/connectDB()
	if(!setup_database_connection())
		to_world_log("Your server failed to establish a connection with the feedback database.")
	else
		to_world_log("Feedback database connection established.")
	return 1

/proc/setup_database_connection()
	if (!sqlenabled)
		return 0
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0
	if(!dbcon)
		dbcon = new()
	var/user = sqlfdbklogin
	var/pass = sqlfdbkpass
	var/db = sqlfdbkdb
	var/address = sqladdress
	var/port = sqlport
	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		to_world_log(dbcon.ErrorMsg())
	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_db_connection()
	if (!sqlenabled)
		return 0
	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0
	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return 1


/hook/startup/proc/connectOldDB()
	if(!setup_old_database_connection())
		to_world_log("Your server failed to establish a connection with the SQL database.")
	else
		to_world_log("SQL database connection established.")
	return 1

//These two procs are for the old database, while it's being phased out. See the tgstation.sql file in the SQL folder for more information.
/proc/setup_old_database_connection()
	if (!sqlenabled)
		return 0
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to conenct anymore.
		return 0
	if(!dbcon_old)
		dbcon_old = new()
	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon_old.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon_old.IsConnected()
	if ( . )
		failed_old_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_old_db_connections++		//If it failed, increase the failed connections counter.
		to_world_log(dbcon.ErrorMsg())
	return .

//This proc ensures that the connection to the feedback database (global variable dbcon) is established
/proc/establish_old_db_connection()
	if (!sqlenabled)
		return 0
	if(failed_old_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return 0

	if(!dbcon_old || !dbcon_old.IsConnected())
		return setup_old_database_connection()
	else
		return 1

#undef RECOMMENDED_VERSION
#undef FAILED_DB_CONNECTION_CUTOFF
#undef THROTTLE_MAX_BURST
#undef SET_THROTTLE
