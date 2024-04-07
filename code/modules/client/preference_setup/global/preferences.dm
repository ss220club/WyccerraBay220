var/global/list/_client_preferences
var/global/list/_client_preferences_by_key
var/global/list/_client_preferences_by_type

/proc/get_client_preferences()
	RETURN_TYPE(/list)
	if(!_client_preferences)
		_client_preferences = list()
		for(var/ct in subtypesof(/datum/client_preference))
			var/datum/client_preference/client_type = ct
			if(initial(client_type.description))
				_client_preferences += new client_type()
	return _client_preferences

/proc/get_client_preference(datum/client_preference/preference)
	RETURN_TYPE(/datum/client_preference)
	if(istype(preference))
		return preference
	if(ispath(preference))
		return get_client_preference_by_type(preference)
	return get_client_preference_by_key(preference)

/proc/get_client_preference_by_key(preference)
	RETURN_TYPE(/datum/client_preference)
	if(!_client_preferences_by_key)
		_client_preferences_by_key = list()
		for(var/ct in get_client_preferences())
			var/datum/client_preference/client_pref = ct
			_client_preferences_by_key[client_pref.key] = client_pref
	return _client_preferences_by_key[preference]

/proc/get_client_preference_by_type(preference)
	RETURN_TYPE(/datum/client_preference)
	if(!_client_preferences_by_type)
		_client_preferences_by_type = list()
		for(var/ct in get_client_preferences())
			var/datum/client_preference/client_pref = ct
			_client_preferences_by_type[client_pref.type] = client_pref
	return _client_preferences_by_type[preference]

/datum/client_preference
	var/description
	var/key
	var/list/options = list(PREF_YES, PREF_NO)
	var/default_value

/datum/client_preference/New()
	. = ..()

	if(!default_value)
		default_value = options[1]

/datum/client_preference/proc/may_set(client/given_client)
	return TRUE

/datum/client_preference/proc/changed(mob/preference_mob, new_value)
	return

/*********************
* Player Preferences *
*********************/

/datum/client_preference/client_view
	description = "Size of playable zone window"
	key = "CLIENT_VIEW"
	options = list(PREF_CLIENT_VIEW_SMALL, PREF_CLIENT_VIEW_MEDIUM, PREF_CLIENT_VIEW_LARGE)
	default_value = PREF_CLIENT_VIEW_LARGE

/datum/client_preference/client_view/changed(mob/preference_mob, new_value)
	var/client/mob_client = preference_mob?.client
	if(!mob_client)
		return

	mob_client.view = new_value
	mob_client.update_skybox(TRUE)

/datum/client_preference/play_admin_midis
	description = "Play admin midis"
	key = "SOUND_MIDI"

/datum/client_preference/play_lobby_music
	description = "Play lobby music"
	key = "SOUND_LOBBY"

/datum/client_preference/play_lobby_music/changed(mob/preference_mob, new_value)
	if(new_value == PREF_YES)
		if(isnewplayer(preference_mob))
			sound_to(preference_mob, GLOB.using_map.lobby_track.get_sound())
			to_chat(preference_mob, GLOB.using_map.lobby_track.get_info())
	else
		sound_to(preference_mob, sound(null, repeat = 0, wait = 0, volume = 85, channel = GLOB.lobby_sound_channel))

/datum/client_preference/play_ambiance
	description = "Play ambience"
	key = "SOUND_AMBIENCE"

/datum/client_preference/play_ambiance/changed(mob/preference_mob, new_value)
	if(new_value == PREF_NO)
		sound_to(preference_mob, sound(null, channel = GLOB.ambience_channel_vents))
		sound_to(preference_mob, sound(null, channel = GLOB.ambience_channel_forced))
		sound_to(preference_mob, sound(null, channel = GLOB.ambience_channel_common))

/datum/client_preference/play_announcement_sfx
	description = "Play announcement sound effects"
	key = "SOUND_ANNOUNCEMENT"
	options = list(PREF_YES, PREF_NO)
/datum/client_preference/ghost_ears
	description = "Ghost ears"
	key = "CHAT_GHOSTEARS"
	options = list(PREF_ALL_SPEECH, PREF_NEARBY)

/datum/client_preference/ghost_sight
	description = "Ghost sight"
	key = "CHAT_GHOSTSIGHT"
	options = list(PREF_ALL_EMOTES, PREF_NEARBY)

/datum/client_preference/ghost_radio
	description = "Ghost radio"
	key = "CHAT_GHOSTRADIO"
	options = list(PREF_ALL_CHATTER, PREF_NEARBY)

/datum/client_preference/language_display
	description = "Show Language Names"
	key = "LANGUAGE_DISPLAY"
	options = list(PREF_SHORTHAND, PREF_FULL, PREF_OFF)

/datum/client_preference/ghost_language_hide
	description = "Hide Language Names As Ghost"
	key = "LANGUAGE_DISPLAY_GHOST"

/datum/client_preference/ghost_follow_link_length
	description = "Ghost Follow Links"
	key = "CHAT_GHOSTFOLLOWLINKLENGTH"
	options = list(PREF_SHORT, PREF_LONG, PREF_OFF)

/datum/client_preference/chat_tags
	description = "Chat tags"
	key = "CHAT_SHOWICONS"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_typing_indicator
	description = "Typing indicator"
	key = "SHOW_TYPING"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_typing_indicator/changed(mob/preference_mob, new_value)
	SStyping.UpdatePreference(preference_mob.client, new_value == PREF_SHOW)

/datum/client_preference/show_ooc
	description = "OOC chat"
	key = "CHAT_OOC"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_aooc
	description = "AOOC chat"
	key = "CHAT_AOOC"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_looc
	description ="LOOC chat"
	key = "CHAT_LOOC"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_dsay
	description ="Dead chat"
	key = "CHAT_DEAD"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_progress_bar
	description ="Progress Bar"
	key = "SHOW_PROGRESS"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/autohiss
	description = "Autohiss"
	key = "AUTOHISS"
	options = list(PREF_OFF, PREF_BASIC, PREF_FULL)

/datum/client_preference/hardsuit_activation
	description = "Hardsuit Module Activation Key"
	key = "HARDSUIT_ACTIVATION"
	options = list(PREF_MIDDLE_CLICK, PREF_CTRL_CLICK, PREF_ALT_CLICK, PREF_CTRL_SHIFT_CLICK)

/datum/client_preference/holster_on_intent
	description = "Draw gun based on intent"
	key = "HOLSTER_ON_INTENT"

/datum/client_preference/safety_toggle_on_intent
	description = "Ignore safety on harm intent"
	key = "SAFETY_ON_INTENT"

/datum/client_preference/show_credits
	description = "Show End Titles"
	key = "SHOW_CREDITS"

/datum/client_preference/show_ckey_credits
	description = "Show Ckey in End Credits/Special Role List"
	key = "SHOW_CKEY_CREDITS"
	options = list(PREF_HIDE, PREF_SHOW)

/datum/client_preference/show_ckey_deadchat
	description = "Show Ckey in Deadchat"
	key = "SHOW_CKEY_DEADCHAT"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_ready
	description = "Show Ready Status in Lobby"
	key = "SHOW_READY"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/announce_ghost_join
	description = "Announce When Joining as Observer"
	key = "ANNOUNCE_GHOST"
	options = list(PREF_YES, PREF_NO)

/datum/client_preference/play_instruments
	description = "Play instruments"
	key = "SOUND_INSTRUMENTS"

/datum/client_preference/give_personal_goals
	description = "Give Personal Goals"
	key = "PERSONAL_GOALS"
	options = list(PREF_NEVER, PREF_NON_ANTAG, PREF_ALWAYS)

/datum/client_preference/show_department_goals
	description = "Show Departmental Goals"
	key = "DEPT_GOALS"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/examine_messages
	description = "Examining messages"
	key = "EXAMINE_MESSAGES"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/graphics_quality
	description = "Graphics quality (where relevant it will reduce effects)"
	key = "GRAPHICS_QUALITY"
	options = list(PREF_LOW, PREF_MED, PREF_HIGH)
	default_value = PREF_HIGH

/datum/client_preference/graphics_quality/changed(mob/preference_mob, new_value)
	if(preference_mob?.client)
		for(var/atom/movable/renderer/R as anything in preference_mob.renderers)
			R.GraphicsUpdate()

/datum/client_preference/tgui_fancy
	description = "Fancy TGUI"
	key = "TGUI_FANCY"
	options = list(PREF_YES, PREF_NO)

/datum/client_preference/tgui_input
	description = "TGUI Input"
	key = "TGUI_INPUT"
	options = list(PREF_YES, PREF_NO)

/datum/client_preference/tgui_input_large
	description = "TGUI Input - Large Buttons"
	key = "TGUI_INPUT_LARGE"
	options = list(PREF_YES, PREF_NO)

/datum/client_preference/tgui_input_swap
	description = "TGUI Input - Swap Buttons"
	key = "TGUI_INPUT_SWAP"
	options = list(PREF_YES, PREF_NO)

/datum/client_preference/tgui_lock
	description = "Lock TGUI"
	key = "TGUI_LOCK"
	options = list(PREF_YES, PREF_NO)
	default_value = PREF_NO

/datum/client_preference/notify_ghost_trap
	description = "Notify when ghost-trap roles are available."
	key = "GHOST_TRAP"
	options = list(PREF_YES, PREF_NO)
	default_value = PREF_YES


/datum/client_preference/surgery_skip_radial
	description = "Skip the radial menu for single-option surgeries."
	key = "SURGERY_SKIP_RADIAL"
	options = list(PREF_YES, PREF_NO)

/datum/client_preference/runechat_mob
	description = "Enable mob runechat"
	key = "RUNECHAT_MOB"
	options = list(PREF_YES, PREF_NO)
	default_value = PREF_YES

/datum/client_preference/runechat_obj
	description = "Enable obj runechat"
	key = "RUNECHAT_OBJ"
	options = list(PREF_YES, PREF_NO)
	default_value = PREF_YES

/datum/client_preference/runechat_messages_length
	description = "Length of runechat messages"
	key = "RUNECHAT_MESSAGES_LENGTH"
	options = list(PREF_SHORT, PREF_LONG)
	default_value = PREF_SHORT


/********************
* General Staff Preferences *
********************/

/datum/client_preference/staff
	var/flags

/datum/client_preference/staff/may_set(client/given_client)
	if(ismob(given_client))
		var/mob/M = given_client
		given_client = M.client
	if(!given_client)
		return FALSE
	if(flags)
		return check_rights(flags, 0, given_client)
	else
		return given_client && given_client.holder

/datum/client_preference/staff/show_chat_prayers
	description = "Chat Prayers"
	key = "CHAT_PRAYER"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/staff/play_adminhelp_ping
	description = "Adminhelps"
	key = "SOUND_ADMINHELP"
	options = list(PREF_HEAR, PREF_SILENT)

/datum/client_preference/staff/show_rlooc
	description = "Remote LOOC chat"
	key = "CHAT_RLOOC"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/ooc_donation_color
	description = "OOC donator color"
	key = "OOC_DONATION_COLOR"
	options = list(PREF_SHOW, PREF_HIDE)

/********************
* Admin Preferences *
********************/

/datum/client_preference/staff/show_attack_logs
	description = "Attack Log Messages"
	key = "CHAT_ATTACKLOGS"
	options = list(PREF_SHOW, PREF_HIDE)
	flags = R_ADMIN
	default_value = PREF_HIDE

/********************
* Debug Preferences *
********************/

/datum/client_preference/staff/show_debug_logs
	description = "Debug Log Messages"
	key = "CHAT_DEBUGLOGS"
	options = list(PREF_SHOW, PREF_HIDE)
	default_value = PREF_HIDE
	flags = R_ADMIN|R_DEBUG


/datum/client_preference/staff/show_runtime_logs
	description = "Runtime Log Messages"
	key = "CHAT_RUNTIMELOGS"
	options = list(PREF_SHOW, PREF_HIDE)
	default_value = PREF_HIDE
	flags = R_ADMIN | R_DEBUG
