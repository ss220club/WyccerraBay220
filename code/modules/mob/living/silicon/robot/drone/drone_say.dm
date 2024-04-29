/mob/living/silicon/robot/drone/say(message)
	if(local_transmit)
		if (src.client)
			if(client.prefs.muted & MUTE_IC)
				to_chat(src, "You cannot send IC messages (muted).")
				return 0

		message = sanitize(message)

		if (stat == DEAD)
			return say_dead(message)

		if(copytext_char(message,1,2) == get_prefix_key(/singleton/prefix/custom_emote))
			return emote(copytext(message,2))

		if(copytext_char(message,1,2) == get_prefix_key(/singleton/prefix/radio_main_channel))
			var/datum/language/L = GLOB.all_languages[LANGUAGE_DRONE_GLOBAL]
			if(istype(L))
				return L.broadcast(src,trimtext(copytext(message,2)))

		//Must be concious to speak
		if (stat)
			return 0

		var/list/listeners = hearers(5,src)
		listeners |= src

		for(var/mob/living/silicon/D in listeners)
			if(D.client && D.local_transmit)
				to_chat(D, "<b>[src]</b> transmits, \"[message]\"")

		for (var/mob/M in GLOB.player_list)
			if (istype(M, /mob/new_player))
				continue
			else if(M.stat == DEAD && M.get_preference_value(/datum/client_preference/ghost_ears) == PREF_ALL_SPEECH)
				if(M.client) to_chat(M, "<b>[src]</b> transmits, \"[message]\"")
		return 1
	return ..(message, 0)
