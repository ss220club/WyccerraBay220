/datum/client_preference/show_screentip
	description = "Screentip"
	key = "SHOW_SCREENTIP"
	options = list(PREF_SHOW, PREF_HIDE)

/datum/client_preference/show_screentip/changed(mob/preference_mob, new_value)
	var/client/C = preference_mob.client
	C.screentip.set_show(new_value == PREF_SHOW)
