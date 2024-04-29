GLOBAL_VAR_CONST(NETWORK_AQUILA, "Aquila")
GLOBAL_VAR_CONST(NETWORK_BRIDGE, "Bridge")
GLOBAL_VAR_CONST(NETWORK_CHARON, "Charon")
GLOBAL_VAR_CONST(NETWORK_FIRST_DECK, "First Deck")
GLOBAL_VAR_CONST(NETWORK_FOURTH_DECK, "Fourth Deck")
GLOBAL_VAR_CONST(NETWORK_SECOND_DECK, "Second Deck")
GLOBAL_VAR_CONST(NETWORK_THIRD_DECK, "Third Deck")
GLOBAL_VAR_CONST(NETWORK_FIFTH_DECK, "Fifth Deck")

/datum/map/torch/get_network_access(network)
	switch(network)
		if(NETWORK_AQUILA)
			return access_aquila
		if(NETWORK_BRIDGE)
			return GLOB.access_heads
		if(NETWORK_CHARON)
			return GLOB.access_expedition_shuttle
		if(GLOB.NETWORK_HELMETS)
			return access_solgov_crew
	return get_shared_network_access(network) || ..()

/datum/map/torch
	// Networks that will show up as options in the camera monitor program
	station_networks = list(
		NETWORK_BRIDGE,
		GLOB.NETWORK_FIRST_DECK,
		GLOB.NETWORK_SECOND_DECK,
		GLOB.NETWORK_THIRD_DECK,
		GLOB.NETWORK_FOURTH_DECK,
		NETWORK_FIFTH_DECK,
		GLOB.NETWORK_ENGINEERING,
		GLOB.NETWORK_MEDICAL,
		GLOB.NETWORK_RESEARCH,
		GLOB.NETWORK_SECURITY,
		NETWORK_AQUILA,
		NETWORK_CHARON,
		GLOB.NETWORK_HELMETS,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		GLOB.NETWORK_THUNDER,
	)

//
// Cameras
//

// Networks
/obj/machinery/camera/network/aquila
	network = list(NETWORK_AQUILA)

/obj/machinery/camera/network/bridge
	network = list(NETWORK_BRIDGE)

/obj/machinery/camera/network/exploration_shuttle
	network = list(NETWORK_CHARON)

/obj/machinery/camera/network/first_deck
	network = list(GLOB.NETWORK_FIRST_DECK)

/obj/machinery/camera/network/fourth_deck
	network = list(GLOB.NETWORK_FOURTH_DECK)

/obj/machinery/camera/network/fifth_deck
	network = list(NETWORK_FIFTH_DECK)

/obj/machinery/camera/network/second_deck
	network = list(GLOB.NETWORK_SECOND_DECK)

/obj/machinery/camera/network/third_deck
	network = list(GLOB.NETWORK_THIRD_DECK)

/obj/machinery/camera/network/crescent
	network = list(GLOB.NETWORK_CRESCENT)

/obj/machinery/camera/network/engineering_outpost
	network = list(GLOB.NETWORK_ENGINEERING_OUTPOST)

// Motion
/obj/machinery/camera/motion/engineering_outpost
	network = list(GLOB.NETWORK_ENGINEERING_OUTPOST)

// All Upgrades
/obj/machinery/camera/all/command
	network = list(NETWORK_BRIDGE)


//
// SMES units
//

// Substation SMES
/obj/machinery/power/smes/buildable/preset/torch/substation
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1) // Note that it gets one more from construction
	_input_maxed = TRUE
	_output_maxed = TRUE

// Substation SMES (charged and with full I/O setting)
/obj/machinery/power/smes/buildable/preset/torch/substation_full
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil = 1)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

/obj/machinery/power/smes/buildable/preset/torch/substation_full/rust
	uncreated_component_parts = list(/obj/item/stock_parts/smes_coil/super_io = 2)

// Supermatter output SMES
/obj/machinery/power/smes/buildable/preset/torch/engine_main
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/super_io = 2,
		/obj/item/stock_parts/smes_coil/super_capacity = 2)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

//RUST Output SMES
/obj/machinery/power/smes/buildable/preset/torch/engine_empty
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/super_io = 2,
		/obj/item/stock_parts/smes_coil/super_capacity = 2)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE

// Shuttle SMES
/obj/machinery/power/smes/buildable/preset/torch/shuttle
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/super_io = 1,
		/obj/item/stock_parts/smes_coil/super_capacity = 1)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

// Hangar SMES. Charges the shuttles so needs a pretty big throughput.
/obj/machinery/power/smes/buildable/preset/torch/hangar
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil/super_io = 2)
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

// Bridge Solars SMES. For those low pop rounds.
/obj/machinery/power/smes/buildable/preset/torch/bridge_solar
	uncreated_component_parts = list(
		/obj/item/stock_parts/smes_coil = 1
	)
	RCon_tag = "Solar - Bridge"
	_input_maxed = TRUE
	_output_maxed = TRUE
	_input_on = TRUE
	_output_on = TRUE
	_fully_charged = TRUE

GLOBAL_VAR_CONST(NETWORK_COMMAND, "Command")
GLOBAL_VAR_CONST(NETWORK_ENGINE, "Engine")
GLOBAL_VAR_CONST(NETWORK_ENGINEERING_OUTPOST, "Engineering Outpost")

/datum/map/proc/get_shared_network_access(network)
	switch(network)
		if(GLOB.NETWORK_COMMAND)
			return GLOB.access_heads
		if(GLOB.NETWORK_ENGINE, GLOB.NETWORK_ENGINEERING_OUTPOST)
			return GLOB.access_engine

/datum/map/torch/default_internal_channels()
	return list(
		num2text(PUB_FREQ)   = list(),
		num2text(AI_FREQ)    = list(GLOB.access_synth),
		num2text(ENT_FREQ)   = list(),
		num2text(ERT_FREQ)   = list(GLOB.access_cent_specops),
		num2text(COMM_FREQ)  = list(GLOB.access_radio_comm),
		num2text(ENG_FREQ)   = list(GLOB.access_radio_eng),
		num2text(MED_FREQ)   = list(GLOB.access_radio_med),
		num2text(MED_I_FREQ) = list(GLOB.access_radio_med),
		num2text(SEC_FREQ)   = list(GLOB.access_radio_sec),
		num2text(SEC_I_FREQ) = list(GLOB.access_radio_sec),
		num2text(SCI_FREQ)   = list(GLOB.access_radio_sci),
		num2text(SUP_FREQ)   = list(GLOB.access_radio_sup),
		num2text(SRV_FREQ)   = list(GLOB.access_radio_serv),
		num2text(EXP_FREQ)   = list(GLOB.access_radio_exp),
		num2text(HAIL_FREQ)  = list(),
	)

/singleton/stock_part_preset/radio/receiver/vent_pump/guppy
	frequency = 1431

/singleton/stock_part_preset/radio/event_transmitter/vent_pump/guppy
	frequency = 1431

/obj/machinery/atmospherics/unary/vent_pump/high_volume/guppy
	stock_part_presets = list(
		/singleton/stock_part_preset/radio/receiver/vent_pump/guppy = 1,
		/singleton/stock_part_preset/radio/event_transmitter/vent_pump/guppy = 1
	)

/singleton/stock_part_preset/radio/receiver/vent_scrubber/guppy
	frequency = 1431

/singleton/stock_part_preset/radio/event_transmitter/vent_scrubber/guppy
	frequency = 1431

/obj/machinery/atmospherics/unary/vent_scrubber/guppy
	stock_part_presets = list(
		/singleton/stock_part_preset/radio/receiver/vent_scrubber/guppy = 1,
		/singleton/stock_part_preset/radio/event_transmitter/vent_scrubber/guppy = 1
	)
