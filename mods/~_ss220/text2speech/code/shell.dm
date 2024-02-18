#define SHELLEO_ERRORLEVEL 1
#define SHELLEO_STDOUT 2
#define SHELLEO_STDERR 3

#define SHELLEO_NAME "data/shelleo."
#define SHELLEO_ERR ".err"
#define SHELLEO_OUT ".out"

#define DELAYED_SHELL "./tools/misc/delayed_shell.py"

SUBSYSTEM_DEF(shell)
	name = "Shell"
	/// Assotiative list id: callback for shell tasks. When the task is completed, python script sends a world topic that asks to execute the corresponding callback.
	var/list/shell_callbacks = list()
	var/last_id = 0
	var/python_interpreter
	var/shell_interpreter
	var/escape_char

/datum/controller/subsystem/shell/Initialize(start_uptime)
	. = ..()
	var/static/list/python_interpreters = list("[MS_WINDOWS]" = "python", "[UNIX]" = "python3")
	var/static/list/escape_chars = list("[MS_WINDOWS]" = "`", "[UNIX]" = "\\")

	python_interpreter = python_interpreters["[world.system_type]"]
	escape_char = escape_chars["[world.system_type]"]

/datum/controller/subsystem/shell/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"Awaiting [length(shell_callbacks)] tasks"})


/datum/controller/subsystem/shell/proc/shelleo_delayed(command, datum/callback/callback)
	if(!initialized)
		return
	var/id = "id[last_id++]"
	shell_callbacks[id] = callback
	command = replace_characters(command, list({"""}={"[escape_char]""}, {"'"}={"[escape_char]'"}))
	var/shell_command = {"[python_interpreter] [DELAYED_SHELL] -port [world.port] -id [id] -command "[command]""}
	to_world(list2params(world.shelleo(shell_command)))

/world/proc/shelleo(command)
	var/static/list/shelleo_ids = list()
	var/stdout = ""
	var/stderr = ""
	var/errorcode = 1
	var/shelleo_id
	var/out_file = ""
	var/err_file = ""

	for(var/seo_id in shelleo_ids)
		if(!shelleo_ids[seo_id])
			shelleo_ids[seo_id] = TRUE
			shelleo_id = "[seo_id]"
			break
	if(!shelleo_id)
		shelleo_id = "[length(shelleo_ids) + 1]"
		shelleo_ids += shelleo_id
		shelleo_ids[shelleo_id] = TRUE
	out_file = "[SHELLEO_NAME][shelleo_id][SHELLEO_OUT]"
	err_file = "[SHELLEO_NAME][shelleo_id][SHELLEO_ERR]"
	var/shell_command = "[command] > [out_file] 2> [err_file]"
	errorcode = shell(shell_command)
	if(fexists(out_file))
		stdout = file2text(out_file)
		fdel(out_file)
	if(fexists(err_file))
		stderr = file2text(err_file)
		fdel(err_file)
	shelleo_ids[shelleo_id] = FALSE

	return list(errorcode, stdout, stderr)

/proc/shell_url_scrub(url)
	var/static/regex/bad_chars_regex = regex("\[^#%&./:=?\\w]*", "g")
	var/scrubbed_url = ""
	var/bad_match = ""
	var/last_good = 1
	var/bad_chars = 1
	do
		bad_chars = bad_chars_regex.Find(url)
		scrubbed_url += copytext(url, last_good, bad_chars)
		if(bad_chars)
			bad_match = url_encode(bad_chars_regex.match)
			scrubbed_url += bad_match
			last_good = bad_chars + length(bad_chars_regex.match)
	while(bad_chars)
	. = scrubbed_url



/proc/apply_sound_effect(effect, filename_input, filename_output)
	if(!effect)
		CRASH("Invalid sound effect chosen.")

	var/taskset
	if(config.ffmpeg_cpuaffinity)
		taskset = "taskset -ac [config.ffmpeg_cpuaffinity]"

	var/command
	switch(effect)
		if(SOUND_EFFECT_RADIO)
			command = {"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log" [filename_output]"}
		if(SOUND_EFFECT_ROBOT)
			command = {"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5" [filename_output]"}
		if(SOUND_EFFECT_RADIO_ROBOT)
			command = {"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, volume=volume=1.5, highpass=f=1000, lowpass=f=3000, acrusher=1:1:50:0:log" [filename_output]"}
		if(SOUND_EFFECT_MEGAPHONE)
			command = {"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log" [filename_output]"}
		if(SOUND_EFFECT_MEGAPHONE_ROBOT)
			command = {"[taskset] ffmpeg -y -hide_banner -loglevel error -i [filename_input] -filter:a "afftfilt=real='hypot(re,im)*sin(0)':imag='hypot(re,im)*cos(0)':win_size=1024:overlap=0.5, deesser=i=0.4, highpass=f=500, lowpass=f=4000, volume=volume=10, acrusher=1:1:45:0:log" [filename_output]"}
		else
			CRASH("Invalid sound effect chosen.")
	var/list/output = SSshell.shelleo_delayed(command)
	var/errorlevel = output[SHELLEO_ERRORLEVEL]
	var/stdout = output[SHELLEO_STDOUT]
	var/stderr = output[SHELLEO_STDERR]
	if(errorlevel)
		error("Error: apply_sound_effect([effect], [filename_input], [filename_output]) - See debug logs.")
		log_debug("apply_sound_effect([effect], [filename_input], [filename_output]) STDOUT: [stdout]")
		log_debug("apply_sound_effect([effect], [filename_input], [filename_output]) STDERR: [stderr]")
		return FALSE
	return TRUE

#undef SHELLEO_ERRORLEVEL
#undef SHELLEO_STDOUT
#undef SHELLEO_STDERR

#undef SHELLEO_NAME
#undef SHELLEO_ERR
#undef SHELLEO_OUT
