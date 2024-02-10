SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = SS_INIT_ASSETS
	flags = SS_NO_FIRE
	var/list/cache = list()
	var/list/preload = list()

/datum/controller/subsystem/assets/Initialize(timeofday)
	for(var/datum/asset/A as anything in typesof(/datum/asset))
		if(type != initial(A._abstract))
			get_asset_datum(type)

	preload = cache.Copy()

	for(var/client/C as anything in GLOB.clients)
		addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(getFilesSlow), C, preload, FALSE), 10)
	return ..()
