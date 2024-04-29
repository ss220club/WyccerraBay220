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
Here was a frequency list, but it got outdated. Check code\__defines\radio.dm instead.
*/

// Away Site Channels
GLOBAL_LIST_INIT(AWAY_FREQS_UNASSIGNED, list(1491, 1493, 1495, 1497, 1499, 1501, 1503, 1505, 1507, 1509))
GLOBAL_LIST_INIT(AWAY_FREQS_ASSIGNED, list("Hailing" = HAIL_FREQ))

GLOBAL_LIST_INIT(radiochannels, list(
	"Common"		= PUB_FREQ,
	"Hailing"		= HAIL_FREQ,
	"Science"		= SCI_FREQ,
	"Command"		= COMM_FREQ,
	"Medical"		= MED_FREQ,
	"Engineering"	= ENG_FREQ,
	"Security" 		= SEC_FREQ,
	"Response Team" = ERT_FREQ,
	"Special Ops" 	= DTH_FREQ,
	"Mercenary" 	= SYND_FREQ,
	"Raider"		= RAID_FREQ,
	"Vox Raider"	= V_RAID_FREQ,
	"Exploration"	= EXP_FREQ,
	"Supply" 		= SUP_FREQ,
	"Service" 		= SRV_FREQ,
	"AI Private"	= AI_FREQ,
	"Entertainment" = ENT_FREQ,
	"Medical (I)"	= MED_I_FREQ,
	"Security (I)"	= SEC_I_FREQ,
	"ICGNV Hound"   = ICCGN_FREQ
))

GLOBAL_LIST_INIT(channel_color_presets, list(
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
))

// central command channels, i.e deathsquid & response teams
GLOBAL_LIST_INIT(CENT_FREQS, list(ERT_FREQ, DTH_FREQ))

// Antag channels, i.e. Syndicate
GLOBAL_LIST_INIT(ANTAG_FREQS, list(SYND_FREQ, RAID_FREQ, V_RAID_FREQ))

//Department channels, arranged lexically
GLOBAL_LIST_INIT(DEPT_FREQS, list(AI_FREQ, COMM_FREQ, ENG_FREQ, MED_FREQ, SEC_FREQ, SCI_FREQ, SRV_FREQ, SUP_FREQ, EXP_FREQ, ENT_FREQ, MED_I_FREQ, SEC_I_FREQ))

#define TRANSMISSION_WIRE	0
#define TRANSMISSION_RADIO	1

/proc/frequency_span_class(frequency)
	// Antags!
	if (frequency in GLOB.ANTAG_FREQS)
		return "syndradio"
	// centcom channels (deathsquid and ert)
	if(frequency in GLOB.CENT_FREQS)
		return "centradio"
	// command channel
	if(frequency == COMM_FREQ)
		return "comradio"
	// AI private channel
	if(frequency == AI_FREQ)
		return "airadio"
	// department radio formatting (poorly optimized, ugh)
	if(frequency == SEC_FREQ)
		return "secradio"
	if (frequency == ENG_FREQ)
		return "engradio"
	if(frequency == SCI_FREQ)
		return "sciradio"
	if(frequency == MED_FREQ)
		return "medradio"
	if(frequency == EXP_FREQ) // exploration
		return "EXPradio"
	if(frequency == SUP_FREQ) // cargo
		return "supradio"
	if(frequency == SRV_FREQ) // service
		return "srvradio"
	if(frequency == ENT_FREQ) //entertainment
		return "entradio"
	if(frequency == MED_I_FREQ) // Medical intercom
		return "mediradio"
	if(frequency == SEC_I_FREQ) // Security intercom
		return "seciradio"
	if (frequency == HAIL_FREQ) // Hailing frequency
		return "hailradio"
	if(frequency in GLOB.DEPT_FREQS)
		return "deptradio"

	// Away site channels
	for (var/channel in GLOB.AWAY_FREQS_ASSIGNED)
		if (GLOB.AWAY_FREQS_ASSIGNED[channel] == frequency)
			return "[lowertext(channel)]radio"

	return "radio"


/proc/assign_away_freq(channel)
	if (!length(GLOB.AWAY_FREQS_UNASSIGNED))
		return FALSE

	if (channel in GLOB.AWAY_FREQS_ASSIGNED)
		return GLOB.AWAY_FREQS_ASSIGNED[channel]

	var/freq = pick_n_take(GLOB.AWAY_FREQS_UNASSIGNED)
	GLOB.AWAY_FREQS_ASSIGNED[channel] = freq
	GLOB.radiochannels[channel] = freq
	return freq




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

GLOBAL_DATUM(radio_controller, /datum/controller/radio)

/hook/startup/proc/createRadioController()
	GLOB.radio_controller = new /datum/controller/radio()
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
		send_to_filter(source, signal, RADIO_DEFAULT, start_point, range)
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
		radio_filter = RADIO_DEFAULT
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
