#define TTS_REPLACEMENTS_FILE_PATH "config/tts_replacements.json"
#define TTS_ACRONYM_REPLACEMENTS "tts_acronym_replacements"
#define TTS_JOB_REPLACEMENTS "tts_job_replacements"

SUBSYSTEM_DEF(tts220)
	name = "Text-to-Speech 220"
	init_order = SS_INIT_DEFAULT
	wait = 1 SECONDS
	runlevels = RUNLEVEL_LOBBY | RUNLEVELS_DEFAULT

	/// All time tts uses
	var/tts_wanted = 0
	/// Amount of errored requests to providers
	var/tts_request_failed = 0
	/// Amount of successfull requests to providers
	var/tts_request_succeeded = 0
	/// Amount of cache hits
	var/tts_reused = 0
	/// Assoc list of request error codes
	var/list/tts_errors = list()
	/// Last errored requests' contents
	var/tts_error_raw = ""

	// Simple Moving Average RPS
	var/list/tts_rps_list = list()
	var/tts_sma_rps = 0

	/// Requests per Second (RPS), only real API requests
	var/tts_rps = 0
	var/tts_rps_counter = 0

	/// Total Requests per Second (TRPS), all TTS request, even reused
	var/tts_trps = 0
	var/tts_trps_counter = 0

	/// Reused Requests per Second (RRPS), only reused requests
	var/tts_rrps = 0
	var/tts_rrps_counter = 0

	var/is_enabled = TRUE
	/// List of all available TTS seeds
	var/list/datum/tts_seed/tts_seeds = list()
	/// List of all available TTS providers
	var/list/datum/tts_provider/tts_providers = list()

	var/tts_requests_queue_limit = 100
	var/tts_rps_limit = 11

	/// General request queue
	var/list/tts_queue = list()
	/// Ffmpeg queue
	var/list/tts_effects_queue = list()
	/// Lazy list of request that need to performed to TTS provider API
	VAR_PRIVATE/list/tts_requests_queue

	/// The channel used for radio tts. Should be an exact one to not spam with radio messages, but queque them instead
	VAR_PRIVATE/tts_channel_radio
	/// List of currently existing binding of atom and sound channel: `atom` => `sound_channel`. SS220 TODO: free channel when atom is detroyed and may be on some other circumstances
	VAR_PRIVATE/list/tts_local_channels_by_owner = list()

	/// Mapping of BYOND gender to TTS gender
	VAR_PRIVATE/list/gender_table = list(
		NEUTER = TTS_GENDER_ANY,
		PLURAL = TTS_GENDER_ANY,
		MALE = TTS_GENDER_MALE,
		FEMALE = TTS_GENDER_FEMALE
	)
	/// Is debug mode enabled or not. Information about `sanitized_messages_cache_hit` and `sanitized_messages_cache_miss` is printed to debug logs each SS fire
	VAR_PRIVATE/debug_mode_enabled = FALSE
	/// Whether or not caching of sanitized messages is performed
	VAR_PRIVATE/sanitized_messages_caching = TRUE
	/// Amount of message duplicates that were sanitized current SS fire. Debug purpose only
	VAR_PRIVATE/sanitized_messages_cache_hit = 0
	/// Amount of unique messages that were sanitized current SS fire. Debug purpose only
	VAR_PRIVATE/sanitized_messages_cache_miss = 0
	/// List of all messages that were sanitized as: `meesage md5 hash` => `message`
	VAR_PRIVATE/list/sanitized_messages_cache = list()

	/// List of all available TTS seed names
	VAR_PRIVATE/list/tts_seeds_names = list()
	/// List of all available TTS seed names, mapped by donator level for faster access
	VAR_PRIVATE/list/tts_seeds_names_by_donator_levels = list()

	/// List of all tts seeds mapped by TTS gender: `tts gender` => `list of seeds`
	VAR_PRIVATE/list/tts_seeds_by_gender
	/// Replacement map for acronyms for proper TTS spelling. Not private because `replacetext` can use only global procs
	var/list/tts_acronym_replacements
	/// Replacement map for jobs for proper TTS spelling
	VAR_PRIVATE/list/tts_job_replacements

/datum/controller/subsystem/tts220/PreInit()
	. = ..()
	for(var/path in subtypesof(/datum/tts_provider))
		var/datum/tts_provider/provider = new path
		tts_providers[provider.name] += provider

	for(var/path in subtypesof(/datum/tts_seed))
		var/datum/tts_seed/seed = new path
		if(seed.value == "STUB")
			continue
		seed.provider = tts_providers[initial(seed.provider.name)]
		tts_seeds[seed.name] = seed
		tts_seeds_names += seed.name
		tts_seeds_names_by_donator_levels["[seed.required_donator_level]"] += list(seed.name)
		LAZYADDASSOCLIST(tts_seeds_by_gender, seed.gender, seed.name)
	tts_seeds_names = sortTim(tts_seeds_names, GLOBAL_PROC_REF(cmp_text_asc))

/datum/controller/subsystem/tts220/Initialize(start_timeofday)
	if(!config.tts_enabled)
		is_enabled = FALSE
		return

	load_replacements()
	tts_channel_radio = GLOB.sound_channels.RequestChannel("TTS_RADIO")

/datum/controller/subsystem/tts220/disable()
	. = ..()
	is_enabled = FALSE

/datum/controller/subsystem/tts220/fire()
	tts_rps = tts_rps_counter
	tts_rps_counter = 0
	tts_trps = tts_trps_counter
	tts_trps_counter = 0
	tts_rrps = tts_rrps_counter
	tts_rrps_counter = 0

	tts_rps_list += tts_rps
	if(length(tts_rps_list) > 15)
		tts_rps_list.Cut(1,2)

	var/rps_sum = 0
	for(var/rps in tts_rps_list)
		rps_sum += rps
	tts_sma_rps = round(rps_sum / length(tts_rps_list), 0.1)

	var/free_rps = clamp(tts_rps_limit - tts_rps, 0, tts_rps_limit)
	var/requests = LAZYCOPY(tts_requests_queue, 1, clamp(LAZYLEN(tts_requests_queue), 0, free_rps) + 1)
	for(var/request in requests)
		var/text = request[1]
		var/datum/tts_seed/seed = request[2]
		var/datum/callback/proc_callback = request[3]
		var/datum/tts_provider/provider = seed.provider
		provider.request(text, seed, proc_callback)
		tts_rps_counter++
	LAZYCUT(tts_requests_queue, 1, clamp(LAZYLEN(tts_requests_queue), 0, free_rps) + 1)

	if(sanitized_messages_caching)
		sanitized_messages_cache.Cut()
		if(debug_mode_enabled)
			log_debug("sanitized_messages_cache: HIT=[sanitized_messages_cache_hit] / MISS=[sanitized_messages_cache_miss]")
		sanitized_messages_cache_hit = 0
		sanitized_messages_cache_miss = 0

/datum/controller/subsystem/tts220/Recover()
	is_enabled = SStts220.is_enabled
	tts_wanted = SStts220.tts_wanted
	tts_request_failed = SStts220.tts_request_failed
	tts_request_succeeded = SStts220.tts_request_succeeded
	tts_reused = SStts220.tts_reused
	tts_acronym_replacements = SStts220.tts_acronym_replacements
	tts_job_replacements = SStts220.tts_job_replacements

/datum/controller/subsystem/tts220/proc/load_replacements()
	if(!fexists(TTS_REPLACEMENTS_FILE_PATH))
		log_debug("No file for TTS replacements located at: [TTS_REPLACEMENTS_FILE_PATH]. No replacements will be applied for TTS.")
		return

	var/tts_replacements_json = file2text(TTS_REPLACEMENTS_FILE_PATH)
	if(!length(tts_replacements_json))
		log_debug("TTS replacements file is empty at: [TTS_REPLACEMENTS_FILE_PATH].")
		return

	var/list/replacements = json_decode(tts_replacements_json)
	tts_acronym_replacements = replacements[TTS_ACRONYM_REPLACEMENTS]
	tts_job_replacements = replacements[TTS_JOB_REPLACEMENTS]

/datum/controller/subsystem/tts220/proc/queue_request(text, datum/tts_seed/seed, datum/callback/proc_callback)
	if(LAZYLEN(tts_requests_queue) > tts_requests_queue_limit)
		is_enabled = FALSE
		to_chat(world, SPAN_INFO("SERVER: очередь запросов превысила лимит, подсистема SStts220 принудительно отключена!"))
		return FALSE

	if(tts_rps_counter < tts_rps_limit)
		var/datum/tts_provider/provider = seed.provider
		provider.request(text, seed, proc_callback)
		tts_rps_counter++
		return TRUE

	LAZYADD(tts_requests_queue, list(list(text, seed, proc_callback)))
	return TRUE

/datum/controller/subsystem/tts220/proc/get_tts(atom/speaker, mob/listener, message, datum/tts_seed/tts_seed, is_local = TRUE, effect = SOUND_EFFECT_NONE, traits = TTS_TRAIT_RATE_FASTER, preSFX = null, postSFX = null)
	if(!is_enabled)
		return
	if(!message)
		return
	if(isnull(listener) || !listener.client)
		return
	if(ispath(tts_seed) && SStts220.tts_seeds[initial(tts_seed.name)])
		tts_seed = SStts220.tts_seeds[initial(tts_seed.name)]
	if(!istype(tts_seed))
		return

	tts_wanted++
	tts_trps_counter++

	var/datum/tts_provider/provider = tts_seed.provider
	if(!provider.is_enabled)
		return
	if(provider.throttle_check())
		return

	var/dirty_text = message
	var/text = sanitize_tts_input(dirty_text)

	if(!text || length_char(text) > MAX_MESSAGE_LEN)
		return

	if(traits & TTS_TRAIT_RATE_FASTER)
		text = provider.rate_faster(text)

	if(traits & TTS_TRAIT_RATE_MEDIUM)
		text = provider.rate_medium(text)

	if(traits & TTS_TRAIT_PITCH_WHISPER)
		text = provider.pitch_whisper(text)

	var/hash = md5(lowertext(text))
	var/filename = "data/tts_cache/[tts_seed.name]/[hash]"


	if(fexists("[filename].ogg"))
		tts_reused++
		tts_rrps_counter++
		play_tts(speaker, listener, filename, is_local, effect, preSFX, postSFX)
		return

	var/datum/callback/play_tts_cb = CALLBACK(src, PROC_REF(play_tts), speaker, listener, filename, is_local, effect, preSFX, postSFX)

	if(LAZYLEN(tts_queue[filename]))
		tts_reused++
		tts_rrps_counter++
		LAZYADD(tts_queue[filename], play_tts_cb)
		return

	queue_request(text, tts_seed, CALLBACK(src, PROC_REF(get_tts_callback), speaker, listener, filename, seed, is_local, effect, preSFX, postSFX))
	LAZYADD(tts_queue[filename], play_tts_cb)

/datum/controller/subsystem/tts220/proc/get_tts_callback(atom/speaker, mob/listener, filename, datum/tts_seed/seed, is_local, effect, preSFX, postSFX, datum/http_response/response)
	var/datum/tts_provider/provider = seed.provider

	// Bail if it errored
	if(response.errored)
		provider.timed_out_requests++
		log_game(SPAN_WARNING("Error connecting to [provider.name] TTS API. Please inform a maintainer or server host."))
		message_admins(SPAN_WARNING("Error connecting to [provider.name] TTS API. Please inform a maintainer or server host."))
		return

	if(response.status_code != 200)
		provider.failed_requests++
		log_game(SPAN_WARNING("Error performing [provider.name] TTS API request (Code: [response.status_code])"))
		message_admins(SPAN_WARNING("Error performing [provider.name] TTS API request (Code: [response.status_code])"))
		tts_request_failed++
		if(response.status_code)
			if(tts_errors["[response.status_code]"])
				tts_errors["[response.status_code]"]++
			else
				tts_errors += "[response.status_code]"
				tts_errors["[response.status_code]"] = 1
		tts_error_raw = response.error
		return

	tts_request_succeeded++

	var/voice = provider.process_response(response)
	if(!voice)
		return

	rustg_file_write_b64decode(voice, "[filename].ogg")

	if(!config.tts_cache_enabled)
		addtimer(CALLBACK(src, PROC_REF(cleanup_tts_file), "[filename].ogg"), 30 SECONDS)

	for(var/datum/callback/cb in tts_queue[filename])
		invoke_async(cb)
		tts_queue[filename] -= cb

	tts_queue -= filename

/datum/controller/subsystem/tts220/proc/play_tts(atom/speaker, mob/listener, filename, is_local = TRUE, effect = SOUND_EFFECT_NONE, preSFX = null, postSFX = null)
	if(isnull(listener) || !listener.client)
		return

	var/voice
	switch(effect)
		if(SOUND_EFFECT_NONE)
			voice = "[filename].ogg"
		if(SOUND_EFFECT_RADIO)
			voice = "[filename]_radio.ogg"
		if(SOUND_EFFECT_ROBOT)
			voice = "[filename]_robot.ogg"
		if(SOUND_EFFECT_RADIO_ROBOT)
			voice = "[filename]_radio_robot.ogg"
		if(SOUND_EFFECT_MEGAPHONE)
			voice = "[filename]_megaphone.ogg"
		if(SOUND_EFFECT_MEGAPHONE_ROBOT)
			voice = "[filename]_megaphone_robot.ogg"
		else
			CRASH("Invalid sound effect chosen.")
	if(effect != SOUND_EFFECT_NONE)
		if(!fexists(voice))
			var/datum/callback/play_tts_cb = CALLBACK(src, PROC_REF(play_tts), speaker, listener, filename, is_local, effect, preSFX, postSFX)
			if(LAZYLEN(tts_effects_queue[voice]))
				LAZYADD(tts_effects_queue[voice], play_tts_cb)
				return
			LAZYADD(tts_effects_queue[voice], play_tts_cb)
			apply_sound_effect(effect, "[filename].ogg", voice)
			for(var/datum/callback/cb in tts_effects_queue[voice])
				tts_effects_queue[voice] -= cb
				if(cb == play_tts_cb)
					continue
				invoke_async(cb)
			tts_effects_queue -= voice

	var/turf/turf_source = get_turf(speaker)

	var/volume = 100

	var/sound/output = sound(voice)
	output.status = SOUND_STREAM
	if(is_local)
		output.channel = get_local_channel_by_owner(speaker)
	else
		output.channel = tts_channel_radio
		output.wait = TRUE

	if(isnull(speaker))
		output.wait = TRUE
		output.volume = volume
		output.environment = -1

		if(output.volume <= 0)
			return

		if(preSFX)
			play_sfx(listener, preSFX, output.channel, output.volume, output.environment)

		sound_to(listener, output)
		return

	if(preSFX)
		play_sfx(listener, preSFX, output.channel, output.volume, output.environment)

	output = listener.playsound_local(turf_source, output, volume)

	if(!output || output.volume <= 0)
		return

	if(postSFX)
		play_sfx(listener, postSFX, output.channel, output.volume, output.environment)

/datum/controller/subsystem/tts220/proc/play_sfx(mob/listener, sfx, channel, volume, environment)
	var/sound/output = sound(sfx)
	output.status = SOUND_STREAM
	output.wait = TRUE
	output.channel = channel
	output.volume = volume
	output.environment = environment
	sound_to(listener, output)

/datum/controller/subsystem/tts220/proc/cleanup_tts_file(filename)
	fdel(filename)

/datum/controller/subsystem/tts220/proc/get_available_seeds(owner)
	var/list/_tts_seeds_names = list()
	_tts_seeds_names |= tts_seeds_names

	if(!ismob(owner))
		return _tts_seeds_names

	var/mob/M = owner

	if(!M.client)
		return _tts_seeds_names

	return _tts_seeds_names

/datum/controller/subsystem/tts220/proc/get_random_seed(owner)
	return pick(get_available_seeds(owner))

/datum/controller/subsystem/tts220/proc/sanitize_tts_input(message)
	var/hash
	if(sanitized_messages_caching)
		hash = md5(lowertext(message))
		if(sanitized_messages_cache[hash])
			sanitized_messages_cache_hit++
			return sanitized_messages_cache[hash]
		sanitized_messages_cache_miss++
	. = message
	. = trim(.)
	var/static/regex/punctuation_check = new(@"[.,?!]\Z")
	if(!punctuation_check.Find(.))
		. += "."
	var/static/regex/html_tags = new(@"<[^>]*>", "g")
	. = html_tags.Replace(., "")
	. = html_decode(.)
	var/static/regex/forbidden_symbols = new(@"[^a-zA-Z0-9а-яА-ЯёЁ,!?+./ \r\n\t:—()-]", "g")
	. = forbidden_symbols.Replace(., "")
	var/static/regex/acronyms = new(@"(?<![a-zA-Zа-яёА-ЯЁ])[a-zA-Zа-яёА-ЯЁ]+?(?![a-zA-Zа-яёА-ЯЁ])", "gm")
	. = replacetext_char(., acronyms, /proc/tts_acronym_replacer)

	if(LAZYLEN(tts_job_replacements))
		for(var/job in tts_job_replacements)
			. = replacetext_char(., job, tts_job_replacements[job])
	. = rustg_latin_to_cyrillic(.)

	var/static/regex/decimals = new(@"-?\d+\.\d+", "g")
	. = replacetext_char(., decimals, GLOBAL_PROC_REF(dec_in_words))

	var/static/regex/numbers = new(@"-?\d+", "g")
	. = replacetext_char(., numbers, GLOBAL_PROC_REF(num_in_words))
	if(sanitized_messages_caching)
		sanitized_messages_cache[hash] = .

/datum/controller/subsystem/tts220/proc/get_tts_by_gender(gender)
	return LAZYACCESS(tts_seeds_by_gender, get_tts_gender(gender))

/datum/controller/subsystem/tts220/proc/get_tts_gender(gender)
	var/tts_gender = gender_table[gender]
	if(!tts_gender)
		log_error("No mapping found for gender `[gender]` in `SStts220.gender_table`")
		return TTS_GENDER_ANY

	return tts_gender

/datum/controller/subsystem/tts220/proc/pick_tts_seed_by_gender(gender)
	var/tts_gender = SStts220.get_tts_gender(gender)
	var/tts_by_gender = LAZYACCESS(SStts220.tts_seeds_by_gender, tts_gender)
	if(!length(tts_by_gender))
		log_debug("No tts for gender `[gender]`, tts_gender: `[tts_gender]`")
		return null

	return pick(tts_by_gender)

/// Proc intended to use with `replacetext`. Is global because `replacetext` cant use non globabl procs.
/proc/tts_acronym_replacer(word)
	if(!word || !LAZYLEN(SStts220.tts_acronym_replacements))
		return word

	var/match = SStts220.tts_acronym_replacements[lowertext(word)]
	return match || word

/datum/controller/subsystem/tts220/proc/get_local_channel_by_owner(owner)
	PRIVATE_PROC(TRUE)
	var/channel = tts_local_channels_by_owner[owner]
	if(isnull(channel))
		channel = GLOB.sound_channels.RequestChannel("[owner]_TTS_CHANNEL")
		tts_local_channels_by_owner[owner] = channel
	return channel
