GLOBAL_VAR_CONST(NETWORK_CALYPSO, "Charon")
GLOBAL_VAR_CONST(NETWORK_EXPEDITION, "Expedition")
GLOBAL_VAR_CONST(NETWORK_POD, "General Utility Pod")
GLOBAL_VAR_CONST(NETWORK_FIRST_DECK, "First Deck")
GLOBAL_VAR_CONST(NETWORK_SECOND_DECK, "Second Deck")
GLOBAL_VAR_CONST(NETWORK_THIRD_DECK, "Third Deck")
GLOBAL_VAR_CONST(NETWORK_FOURTH_DECK, "Fourth Deck")
GLOBAL_VAR_CONST(NETWORK_BRIDGE_DECK, "Bridge Deck")
GLOBAL_VAR_CONST(NETWORK_SUPPLY, "Supply")
GLOBAL_VAR_CONST(NETWORK_HANGAR, "Hangar")
GLOBAL_VAR_CONST(NETWORK_PETROV, "Petrov")

//Overrides
GLOBAL_VAR_CONST(NETWORK_COMMAND, "Command")
GLOBAL_VAR_CONST(NETWORK_ENGINE, "Engine")
GLOBAL_VAR_CONST(NETWORK_ENGINEERING_OUTPOST, "Engineering Outpost")


/datum/map/sierra/get_network_access(network)
	switch(network)
		if(GLOB.NETWORK_CALYPSO)
			return GLOB.access_expedition_shuttle
		if(GLOB.NETWORK_POD)
			return GLOB.access_guppy
		if(GLOB.NETWORK_SUPPLY)
			return GLOB.access_mailsorting
		if(GLOB.NETWORK_HANGAR)
			return GLOB.access_hangar
		if(GLOB.NETWORK_PETROV)
			return GLOB.access_petrov
		if(GLOB.NETWORK_EXPEDITION)
			return GLOB.access_expedition_shuttle
	return get_shared_network_access(network) || ..()

/datum/map/sierra
	// Networks that will show up as options in the camera monitor program
	station_networks = list(
		GLOB.NETWORK_FIRST_DECK,
		GLOB.NETWORK_SECOND_DECK,
		GLOB.NETWORK_THIRD_DECK,
		GLOB.NETWORK_FOURTH_DECK,
		GLOB.NETWORK_BRIDGE_DECK,
		GLOB.NETWORK_COMMAND,
		GLOB.NETWORK_ENGINEERING,
		GLOB.NETWORK_ENGINE,
		GLOB.NETWORK_MEDICAL,
		GLOB.NETWORK_RESEARCH,
		GLOB.NETWORK_SECURITY,
		GLOB.NETWORK_SUPPLY,
		GLOB.NETWORK_MINE,
		GLOB.NETWORK_EXPEDITION,
		GLOB.NETWORK_HANGAR,
		GLOB.NETWORK_CALYPSO,
		GLOB.NETWORK_PETROV,
		GLOB.NETWORK_POD,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		GLOB.NETWORK_THUNDER,
	)

	high_secure_areas = list(
		"Second Deck - AI Upload",
		"Second Deck - AI Upload Access"
	)

	secure_areas = list(
		"Second Deck - Engine - Supermatter",
		"Second Deck - Engineering - Technical Storage",
		"Second Deck - Teleporter",
		"First Deck - Telecoms - Storage",
		"First Deck - Telecoms - Monitoring",
		"First Deck - Telecoms",
		"Security - Brig",
		"Security - Prison Wing",
		"Third Deck - Hangar",
		"Third Deck - Hangar - Atmospherics Storage",
		"Third Deck - Water Cistern"
	)

//
// Cameras
//

// Networks

/obj/machinery/camera/network/exploration_shuttle
	network = list(GLOB.NETWORK_CALYPSO)

/obj/machinery/camera/network/expedition
	network = list(GLOB.NETWORK_EXPEDITION)

/obj/machinery/camera/network/first_deck
	network = list(GLOB.NETWORK_FIRST_DECK)

/obj/machinery/camera/network/second_deck
	network = list(GLOB.NETWORK_SECOND_DECK)

/obj/machinery/camera/network/third_deck
	network = list(GLOB.NETWORK_THIRD_DECK)

/obj/machinery/camera/network/fourth_deck
	network = list(GLOB.NETWORK_FOURTH_DECK)

/obj/machinery/camera/network/bridge_deck
	network = list(GLOB.NETWORK_BRIDGE_DECK)

/obj/machinery/camera/network/pod
	network = list(GLOB.NETWORK_POD)

/obj/machinery/camera/network/petrov
	network = list(GLOB.NETWORK_PETROV)

/obj/machinery/camera/network/supply
	network = list(GLOB.NETWORK_SUPPLY)

/obj/machinery/camera/network/hangar
	network = list(GLOB.NETWORK_HANGAR)

/obj/machinery/camera/network/command
	network = list(GLOB.NETWORK_COMMAND)

/obj/machinery/camera/network/crescent
	network = list(GLOB.NETWORK_CRESCENT)

/obj/machinery/camera/network/engine
	network = list(GLOB.NETWORK_ENGINE)

/obj/machinery/camera/network/engineering_outpost
	network = list(GLOB.NETWORK_ENGINEERING_OUTPOST)

// Motion
/obj/machinery/camera/motion/engineering_outpost
	network = list(GLOB.NETWORK_ENGINEERING_OUTPOST)

// All Upgrades
/obj/machinery/camera/all/command
	network = list(GLOB.NETWORK_COMMAND)

/datum/map/proc/get_shared_network_access(network)
	switch(network)
		if(GLOB.NETWORK_COMMAND)
			return GLOB.access_heads
		if(GLOB.NETWORK_ENGINE, GLOB.NETWORK_ENGINEERING_OUTPOST)
			return GLOB.access_engine

/datum/computer_file/program/merchant

/obj/machinery/computer/shuttle_control/merchant

/turf/simulated/wall //landlubbers go home
	name = "bulkhead"

/turf/simulated/floor
	name = "bare deck"

/turf/simulated/floor/tiled
	name = "deck"

/singleton/flooring/tiling
	name = "deck"
