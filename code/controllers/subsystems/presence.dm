

/// Builds a list of z-level populations to allow for easier pauses on processing when nobody is around to care
SUBSYSTEM_DEF(presence)
	name = "Player Presence"
	priority = FIRE_PRIORITY_PRESENCE
	wait = 2 SECONDS
	var/static/list/levels = list()
	var/static/list/queue = list()
	var/static/list/build = list()

/datum/controller/subsystem/presence/Recover()
	queue.Cut()
	build.Cut()

/datum/controller/subsystem/presence/UpdateStat(text)
	return ..("Queue: [length(queue)]")

/datum/controller/subsystem/presence/fire(resume, no_mc_tick)
	if(!resume)
		queue = GLOB.player_list.Copy()
		build = list()

	while(length(queue))
		var/mob/living/player_to_check = queue[length(queue)]
		if(!QDELETED(player_to_check) && player_to_check.stat < DEAD)
			build["[get_z(player_to_check)]"]++

		LIST_DEC(queue)

		if(no_mc_tick)
			CHECK_TICK
		else if(MC_TICK_CHECK)
			return

	levels = build

#ifndef UNIT_TEST

/datum/controller/subsystem/presence/flags = SS_NO_INIT

/// 0, or the number of living players on level
/datum/controller/subsystem/presence/proc/population(level)
	return levels["[level]"] || 0

#else

/datum/controller/subsystem/presence/flags = SS_NO_INIT | SS_NO_FIRE

/datum/controller/subsystem/presence/proc/population(level)
	return 1

#endif
