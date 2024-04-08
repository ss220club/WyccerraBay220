GLOBAL_LIST_EMPTY(spacevines_spawned)

/datum/event/spacevine
	announceWhen	= 60

/datum/event/spacevine/start()
	spacevine_infestation()
	GLOB.spacevines_spawned = 1

/datum/event/spacevine/announce()
	level_seven_announcement()
