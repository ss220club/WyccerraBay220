/*
HOW IT WORKS

The radio_controller is a global object maintaining all radio transmissions, think about it as about "ether".
Note that walkie-talkie, intercoms and headsets handle transmission using nonstandard way.
procs:

	add_object(obj/device as obj, var/new_frequency as num, var/filter as text|null = null)
	  Adds listening object.
	  parameters:
		device - device receiving signals, must have proc receive_signal (see description below).
		  one device may listen several frequencies, but not same frequency twice.
		new_frequency - see possibly frequencies below;
		filter - thing for optimization. Optional, but recommended.
				All filters should be consolidated in this file, see defines later.
				Device without listening filter will receive all signals (on specified frequency).
				Device with filter will receive any signals sent without filter.
				Device with filter will not receive any signals sent with different filter.
	  returns:
	   Reference to frequency object.

	remove_object (obj/device, old_frequency)
	  Obliviously, after calling this proc, device will not receive any signals on old_frequency.
	  Other frequencies will left unaffected.

return_frequency(var/frequency as num)
	  returns:
	   Reference to frequency object. Use it if you need to send and do not need to listen.

radio_frequency is a global object maintaining list of devices that listening specific frequency.
procs:

	post_signal(obj/source as obj|null, datum/signal/signal, var/filter as text|null = null, var/range as num|null = null)
	  Sends signal to all devices that wants such signal.
	  parameters:
		source - object, emitted signal. Usually, devices will not receive their own signals.
		signal - see description below.
		filter - described above.
		range - radius of regular byond's square circle on that z-level. null means everywhere, on all z-levels.

obj/proc/receive_signal(datum/signal/signal, var/receive_method as num, var/receive_param)
	Handler from received signals. By default does nothing. Define your own for your object.
	Avoid of sending signals directly from this proc, use spawn(-1). DO NOT use sleep() here or call procs that sleep please. If you must, use spawn()
	  parameters:
		signal - see description below. Extract all needed data from the signal before doing sleep(), spawn() or return!
		receive_method - may be TRANSMISSION_WIRE or TRANSMISSION_RADIO.
		  TRANSMISSION_WIRE is currently unused.
		receive_param - for TRANSMISSION_RADIO here comes frequency.

datum/signal
	vars:
	source
	  an object that emitted signal. Used for debug and bearing.
	data
	  list with transmitting data. Usual use pattern:
		data["msg"] = "hello world"
	encryption
	  Some number symbolizing "encryption key".
	  Note that game actually do not use any cryptography here.
	  If receiving object don't know right key, it must ignore encrypted signal in its receive_signal.

*/

/*
Frequency range: 1200 to 1600
Radiochat range: 1441 to 1489 (most devices refuse to be tune to other frequency, even during mapmaking)

Radio:
1459 - standard radio chat
1351 - Science
1353 - Command
1355 - Medical
1357 - Engineering
1359 - Security
1341 - deathsquad
1443 - Confession Intercom
1347 - Cargo techs
1349 - Service people

1491-1509 - Away sites

Devices:
1451 - tracking implant
1457 - RSD default

On the map:
1311 for prison shuttle console (in fact, it is not used)
1435 for status displays
1437 for atmospherics/fire alerts
1438 for engine components
1439 for air pumps, air scrubbers, atmo control
1441 for atmospherics - supply tanks
1443 for atmospherics - distribution loop/mixed air tank
1445 for bot nav beacons
1447 for mulebot, secbot and ed209 control
1449 for airlock controls, electropack, magnets
1451 for toxin lab access
1453 for engineering access
1455 for AI access
*/

GLOBAL_VAR_CONST(RADIO_LOW_FREQ, 1200)
GLOBAL_VAR_CONST(PUBLIC_LOW_FREQ, 1441)
GLOBAL_VAR_CONST(PUBLIC_HIGH_FREQ, 1489)
GLOBAL_VAR_CONST(RADIO_HIGH_FREQ, 1600)

GLOBAL_VAR_CONST(BOT_FREQ, 1447)
GLOBAL_VAR_CONST(COMM_FREQ, 1353)
GLOBAL_VAR_CONST(ERT_FREQ, 1345)
GLOBAL_VAR_CONST(AI_FREQ, 1343)
GLOBAL_VAR_CONST(ENT_FREQ, 1461) //entertainment frequency. This is not a diona exclusive frequency.
GLOBAL_VAR_CONST(ICCGN_FREQ, 1344)
GLOBAL_VAR_CONST(SFV_FREQ, 1346)

//antagonist channels
GLOBAL_VAR_CONST(DTH_FREQ, 1341)
GLOBAL_VAR_CONST(SYND_FREQ, 1213)
GLOBAL_VAR_CONST(RAID_FREQ, 1277)
GLOBAL_VAR_CONST(V_RAID_FREQ, 1245)

// department channels
GLOBAL_VAR_CONST(PUB_FREQ, 1459)
GLOBAL_VAR_CONST(HAIL_FREQ, 1463)
GLOBAL_VAR_CONST(SEC_FREQ, 1359)
GLOBAL_VAR_CONST(ENG_FREQ, 1357)
GLOBAL_VAR_CONST(MED_FREQ, 1355)
GLOBAL_VAR_CONST(SCI_FREQ, 1351)
GLOBAL_VAR_CONST(SRV_FREQ, 1349)
GLOBAL_VAR_CONST(SUP_FREQ, 1347)
GLOBAL_VAR_CONST(EXP_FREQ, 1361)

// internal department channels
GLOBAL_VAR_CONST(MED_I_FREQ, 1485)
GLOBAL_VAR_CONST(SEC_I_FREQ, 1475)

// Away Site Channels
var/global/list/AWAY_FREQS_UNASSIGNED = list(1491, 1493, 1495, 1497, 1499, 1501, 1503, 1505, 1507, 1509)
var/global/list/AWAY_FREQS_ASSIGNED = list("Hailing" = GLOB.HAIL_FREQ)

// Device signal frequencies
GLOBAL_VAR_CONST(ATMOS_ENGINE_FREQ, 1438) // Used by atmos monitoring in the engine.
GLOBAL_VAR_CONST(PUMP_FREQ, 1439) // Used by air alarms and their progeny.
GLOBAL_VAR_CONST(FUEL_FREQ, 1447) // Used by fuel atmos stuff, and currently default for digital valves
GLOBAL_VAR_CONST(ATMOS_TANK_FREQ, 1441) // Used for gas tank sensors and monitoring.
GLOBAL_VAR_CONST(ATMOS_DIST_FREQ, 1443) // Alternative atmos frequency.
GLOBAL_VAR_CONST(BUTTON_FREQ, 1301) // Used by generic buttons controlling stuff
GLOBAL_VAR_CONST(BLAST_DOORS_FREQ, 1303) // Used by blast doors, buttons controlling them, and mass drivers.
GLOBAL_VAR_CONST(AIRLOCK_FREQ, 1305) // Used by airlocks and buttons controlling them.
GLOBAL_VAR_CONST(SHUTTLE_AIR_FREQ, 1331) // Used by shuttles and shuttle-related atmos systems.
GLOBAL_VAR_CONST(AIRLOCK_AIR_FREQ, 1379) // Used by some airlocks for atmos devices.
GLOBAL_VAR_CONST(EXTERNAL_AIR_FREQ, 1380) // Used by some external airlocks.

var/global/list/radiochannels = list(
	"Common"		= GLOB.PUB_FREQ,
	"Hailing"		= GLOB.HAIL_FREQ,
	"Science"		= GLOB.SCI_FREQ,
	"Command"		= GLOB.COMM_FREQ,
	"Medical"		= GLOB.MED_FREQ,
	"Engineering"	= GLOB.ENG_FREQ,
	"Security" 		= GLOB.SEC_FREQ,
	"Response Team" = GLOB.ERT_FREQ,
	"Special Ops" 	= GLOB.DTH_FREQ,
	"Mercenary" 	= GLOB.SYND_FREQ,
	"Raider"		= GLOB.RAID_FREQ,
	"Vox Raider"	= GLOB.V_RAID_FREQ,
	"Exploration"	= GLOB.EXP_FREQ,
	"Supply" 		= GLOB.SUP_FREQ,
	"Service" 		= GLOB.SRV_FREQ,
	"AI Private"	= GLOB.AI_FREQ,
	"Entertainment" = GLOB.ENT_FREQ,
	"Medical (I)"	= GLOB.MED_I_FREQ,
	"Security (I)"	= GLOB.SEC_I_FREQ,
	"ICGNV Hound"   = GLOB.ICCGN_FREQ
)

var/global/list/channel_color_presets = list(
	"Bemoaning Brown" = COMMS_COLOR_SUPPLY,
	"Bitchin' Blue" = COMMS_COLOR_COMMAND,
	"Bold Brass" = COMMS_COLOR_EXPLORER,
	"Gastric Green" = COMMS_COLOR_SERVICE,
	"Global Green" = COMMS_COLOR_COMMON,
	"Grand Gold" = COMMS_COLOR_COLONY,
	"Hippin' Hot Pink" = COMMS_COLOR_HAILING,
	"Menacing Maroon" = COMMS_COLOR_SYNDICATE,
	"Operational Orange" = COMMS_COLOR_ENGINEER,
	"Painful Pink" = COMMS_COLOR_AI,
	"Phenomenal Purple" = COMMS_COLOR_SCIENCE,
	"Powerful Plum" = COMMS_COLOR_BEARCAT,
	"Pretty Periwinkle" = COMMS_COLOR_CENTCOM,
	"Radical Ruby" = COMMS_COLOR_VOX,
	"Raging Red" = COMMS_COLOR_SECURITY,
	"Spectacular Silver" = COMMS_COLOR_ENTERTAIN,
	"Tantalizing Turquoise" = COMMS_COLOR_MEDICAL,
	"Viewable Violet" = COMMS_COLOR_SKRELL
)

// central command channels, i.e deathsquid & response teams
var/global/list/CENT_FREQS = list(GLOB.ERT_FREQ, GLOB.DTH_FREQ)

// Antag channels, i.e. Syndicate
var/global/list/ANTAG_FREQS = list(GLOB.SYND_FREQ, GLOB.RAID_FREQ, GLOB.V_RAID_FREQ)

//Department channels, arranged lexically
var/global/list/DEPT_FREQS = list(GLOB.AI_FREQ, GLOB.COMM_FREQ, GLOB.ENG_FREQ, GLOB.MED_FREQ, GLOB.SEC_FREQ, GLOB.SCI_FREQ, GLOB.SRV_FREQ, GLOB.SUP_FREQ, GLOB.EXP_FREQ, GLOB.ENT_FREQ, GLOB.MED_I_FREQ, GLOB.SEC_I_FREQ)

#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

/proc/frequency_span_class(frequency)
	// Antags!
	if (frequency in ANTAG_FREQS)
		return "syndradio"
	// centcom channels (deathsquid and ert)
	if(frequency in CENT_FREQS)
		return "centradio"
	// command channel
	if(frequency == GLOB.COMM_FREQ)
		return "comradio"
	// AI private channel
	if(frequency == GLOB.AI_FREQ)
		return "airadio"
	// department radio formatting (poorly optimized, ugh)
	if(frequency == GLOB.SEC_FREQ)
		return "secradio"
	if (frequency == GLOB.ENG_FREQ)
		return "engradio"
	if(frequency == GLOB.SCI_FREQ)
		return "sciradio"
	if(frequency == GLOB.MED_FREQ)
		return "medradio"
	if(frequency == GLOB.EXP_FREQ) // exploration
		return "EXPradio"
	if(frequency == GLOB.SUP_FREQ) // cargo
		return "supradio"
	if(frequency == GLOB.SRV_FREQ) // service
		return "srvradio"
	if(frequency == GLOB.ENT_FREQ) //entertainment
		return "entradio"
	if(frequency == GLOB.MED_I_FREQ) // Medical intercom
		return "mediradio"
	if(frequency == GLOB.SEC_I_FREQ) // Security intercom
		return "seciradio"
	if (frequency == GLOB.HAIL_FREQ) // Hailing frequency
		return "hailradio"
	if(frequency in DEPT_FREQS)
		return "deptradio"

	// Away site channels
	for (var/channel in AWAY_FREQS_ASSIGNED)
		if (AWAY_FREQS_ASSIGNED[channel] == frequency)
			return "[lowertext(channel)]radio"

	return "radio"


/proc/assign_away_freq(channel)
	if (!length(AWAY_FREQS_UNASSIGNED))
		return FALSE

	if (channel in AWAY_FREQS_ASSIGNED)
		return AWAY_FREQS_ASSIGNED[channel]

	var/freq = pick_n_take(AWAY_FREQS_UNASSIGNED)
	AWAY_FREQS_ASSIGNED[channel] = freq
	radiochannels[channel] = freq
	return freq


/* filters */
//When devices register with the radio controller, they might register under a certain filter.
//Other devices can then choose to send signals to only those devices that belong to a particular filter.
//This is done for performance, so we don't send signals to lots of machines unnecessarily.

//This filter is special because devices belonging to default also recieve signals sent to any other filter.
GLOBAL_VAR_CONST(RADIO_DEFAULT, "radio_default")

GLOBAL_VAR_CONST(RADIO_TO_AIRALARM, "radio_airalarm") //air alarms
GLOBAL_VAR_CONST(RADIO_FROM_AIRALARM, "radio_airalarm_rcvr") //devices interested in recieving signals from air alarms
GLOBAL_VAR_CONST(RADIO_CHAT, "radio_telecoms")
GLOBAL_VAR_CONST(RADIO_ATMOSIA, "radio_atmos")
GLOBAL_VAR_CONST(RADIO_NAVBEACONS, "radio_navbeacon")
GLOBAL_VAR_CONST(RADIO_AIRLOCK, "radio_airlock")
GLOBAL_VAR_CONST(RADIO_SECBOT, "radio_secbot")
GLOBAL_VAR_CONST(RADIO_MULEBOT, "radio_mulebot")
GLOBAL_VAR_CONST(RADIO_MAGNETS, "radio_magnet")

// These are exposed to players, by name.
GLOBAL_LIST_INIT(all_selectable_radio_filters, list(
	RADIO_DEFAULT,
	RADIO_TO_AIRALARM,
	RADIO_FROM_AIRALARM,
	RADIO_CHAT,
	RADIO_ATMOSIA,
	RADIO_NAVBEACONS,
	RADIO_AIRLOCK,
	RADIO_SECBOT,
	RADIO_MULEBOT,
	RADIO_MAGNETS
))

var/global/datum/controller/radio/radio_controller

/hook/startup/proc/createRadioController()
	radio_controller = new /datum/controller/radio()
	return 1

//callback used by objects to react to incoming radio signals
/obj/proc/receive_signal(datum/signal/signal, receive_method, receive_param)
	set waitfor = FALSE
	return null

//The global radio controller
/datum/controller/radio
	var/list/datum/radio_frequency/frequencies = list()

/datum/controller/radio/proc/add_object(obj/device as obj, new_frequency as num, object_filter = null as text|null)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new
		frequency.frequency = new_frequency
		frequencies[f_text] = frequency

	frequency.add_listener(device, object_filter)
	return frequency

/datum/controller/radio/proc/remove_object(obj/device, old_frequency)
	var/f_text = num2text(old_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(frequency)
		frequency.remove_listener(device)

		if(length(frequency.devices) == 0)
			qdel(frequency)
			frequencies -= f_text

	return 1

/datum/controller/radio/proc/return_frequency(new_frequency as num)
	var/f_text = num2text(new_frequency)
	var/datum/radio_frequency/frequency = frequencies[f_text]

	if(!frequency)
		frequency = new
		frequency.frequency = new_frequency
		frequencies[f_text] = frequency

	return frequency

/datum/radio_frequency
	var/frequency as num
	var/list/list/obj/devices = list()

/datum/radio_frequency/proc/post_signal(obj/source as obj|null, datum/signal/signal, radio_filter = null as text|null, range = null as num|null)
	var/turf/start_point
	if(range)
		start_point = get_turf(source)
		if(!start_point)
			qdel(signal)
			return 0
	if (radio_filter)
		send_to_filter(source, signal, radio_filter, start_point, range)
		send_to_filter(source, signal, GLOB.RADIO_DEFAULT, start_point, range)
	else
		//Broadcast the signal to everyone!
		for (var/next_filter in devices)
			send_to_filter(source, signal, next_filter, start_point, range)

//Sends a signal to all machines belonging to a given filter. Should be called by post_signal()
/datum/radio_frequency/proc/send_to_filter(obj/source, datum/signal/signal, radio_filter, turf/start_point = null, range = null)
	var/list/z_levels
	if(start_point)
		z_levels = GetConnectedZlevelsSet(start_point.z)

	for(var/obj/device as anything in devices[radio_filter])
		if(device == source)
			continue
		var/turf/end_point = get_turf(device)
		if(!end_point)
			continue
		if(z_levels && !(z_levels["[end_point.z]"]))
			continue
		if(range && get_dist(start_point, end_point) > range)
			continue

		device.receive_signal(signal, TRANSMISSION_RADIO, frequency)

/datum/radio_frequency/proc/add_listener(obj/device as obj, radio_filter as text|null)
	if (!radio_filter)
		radio_filter = GLOB.RADIO_DEFAULT
	var/list/obj/devices_line = devices[radio_filter]
	if (!devices_line)
		devices_line = new
		devices[radio_filter] = devices_line
	devices_line |= device

/datum/radio_frequency/proc/remove_listener(obj/device)
	for (var/devices_filter in devices)
		var/list/devices_line = devices[devices_filter]
		devices_line-=device
		while (null in devices_line)
			devices_line -= null
		if (length(devices_line)==0)
			devices -= devices_filter

/datum/signal
	var/obj/source

	var/transmission_method = 0 //unused at the moment
	//0 = wire
	//1 = radio transmission
	//2 = subspace transmission

	var/list/data = list()
	var/encryption

	var/frequency = 0

/datum/signal/proc/copy_from(datum/signal/model)
	source = model.source
	transmission_method = model.transmission_method
	data = model.data
	encryption = model.encryption
	frequency = model.frequency

/datum/signal/proc/debug_print()
	if (source)
		. = "signal = {source = '[source]' ([source:x],[source:y],[source:z])\n"
	else
		. = "signal = {source = '[source]' ()\n"
	for (var/i in data)
		. += "data\[\"[i]\"\] = \"[data[i]]\"\n"
		if(islist(data[i]))
			var/list/L = data[i]
			for(var/t in L)
				. += "data\[\"[i]\"\] list has: [t]"
