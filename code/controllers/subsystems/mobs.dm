SUBSYSTEM_DEF(mobs)
	name = "Mobs"
	priority = FIRE_PRIORITY_MOB
	flags = SS_NO_INIT | SS_KEEP_TIMING
	wait = 2 SECONDS
	/// List of all mobs currently present in world
	var/static/list/mob/all_mobs
	/// List of all mobs currently present in world by type
	var/static/list/mob/mobs_by_type
	var/static/list/mob/mob_list = list()
	var/static/list/mob/queue = list()


/datum/controller/subsystem/mobs/UpdateStat(time)
	if (PreventUpdateStat(time))
		return ..()
	..({"\
		Mobs: [length(mob_list)] \
		Run Empty Levels: [config.run_empty_levels ? "Y" : "N"]\
	"})


/datum/controller/subsystem/mobs/Recover()
	queue.Cut()


/datum/controller/subsystem/mobs/fire(resume, no_mc_tick)
	if (!resume)
		queue = mob_list.Copy()
	var/cut_until = 1
	for (var/mob/mob as anything in queue)
		++cut_until
		if (QDELETED(mob))
			continue
		if (!config.run_empty_levels && !SSpresence.population(get_z(mob)))
			continue
		mob.Life()
		if (no_mc_tick)
			CHECK_TICK
		else if (MC_TICK_CHECK)
			queue.Cut(1, cut_until)
			return
	queue.Cut()

/datum/controller/subsystem/mobs/proc/register_mob(mob/mob_to_register)
	if(!istype(mob_to_register))
		CRASH("Invalid mob being registered: [mob_to_register]")

	LAZYADD(all_mobs, mob_to_register)
	LAZYADDASSOCLIST(mobs_by_type, mob_to_register.type, mob_to_register)

/datum/controller/subsystem/mobs/proc/unregister_mob(mob/mob_to_unregister)
	if(!istype(mob_to_unregister))
		CRASH("Invalid mob being unregistered: [mob_to_unregister]")

	LAZYREMOVE(all_mobs, mob_to_unregister)
	LAZYREMOVEASSOC(mobs_by_type, mob_to_unregister.type, mob_to_unregister)

/datum/controller/subsystem/mobs/proc/get_all_mobs()
	return all_mobs.Copy()

/datum/controller/subsystem/mobs/proc/get_mobs_of_type(mob/type)
	if(istype(type))
		var/mob/passed_mob = type
		type = passed_mob.type

	if(!ispath(type))
		stack_trace("Non-mob type passed in `/datum/controller/subsystem/mobs/proc/get_mobs_of_type`")
		return list()

	if(type == /mob)
		return get_all_mobs()

	var/list/desired_mobs = list()
	for(var/mob/mob_type as anything in typesof(type))
		var/list/mobs_of_type = mobs_by_type[mob_type]
		if(!length(mobs_of_type))
			continue

		desired_mobs += mobs_of_type

	return desired_mobs

#define START_PROCESSING_MOB(MOB) \
if (MOB.is_processing) {\
	if (MOB.is_processing != SSmobs) {\
		crash_with("Failed to start processing mob. Already being processed by [MOB.is_processing].")\
	}\
}\
else {\
	MOB.is_processing = SSmobs;\
	SSmobs.mob_list += MOB;\
}


#define STOP_PROCESSING_MOB(MOB) \
if(MOB.is_processing == SSmobs) {\
	MOB.is_processing = null;\
	SSmobs.mob_list -= MOB;\
	SSmobs.queue -= MOB;\
}\
else if (MOB.is_processing) {\
	crash_with("Failed to stop processing mob. Being processed by [MOB.is_processing] instead.")\
}
