/datum/configuration
	var/tts_enabled
	var/tts_token_silero
	var/tts_cache_enabled
	var/ffmpeg_cpuaffinity
	var/tts_api_url_silero

/datum/configuration/vv_get_var(var_name)
	if(var_name == "body")
		return FALSE

/datum/configuration/vv_get_var(var_name, var_value)
	if(var_name == "tts_api_url_silero")
		return FALSE
