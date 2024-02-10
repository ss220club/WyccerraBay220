/datum/client_preference/bloomlevel
	description = "Bloom level"
	key = "BLOOMLEVEL"
	options = list(GLOB.PREF_OFF, GLOB.PREF_LOW, GLOB.PREF_MED, GLOB.PREF_HIGH)
	default_value = GLOB.PREF_MED

/datum/client_preference/bloomlevel/changed(mob/preference_mob, new_value)
	if(preference_mob?.client)
		for(var/atom/movable/renderer/R as anything in preference_mob.renderers)
			R.GraphicsUpdate()

/datum/client_preference/glare
	description = "Show lamp glare"
	key = "GLARE"
	options = list(GLOB.PREF_YES, GLOB.PREF_NO)
	default_value = GLOB.PREF_YES

/datum/client_preference/glare/changed(mob/preference_mob, new_value)
	if(preference_mob?.client)
		for(var/atom/movable/renderer/R as anything in preference_mob.renderers)
			if (istype(R, /atom/movable/renderer/lamps_glare))
				R.GraphicsUpdate()
