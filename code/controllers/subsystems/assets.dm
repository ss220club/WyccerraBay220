SUBSYSTEM_DEF(assets)
	name = "Assets"
	init_order = SS_INIT_ASSETS
	flags = SS_NO_FIRE
	var/list/datum/asset_cache_item/cache = list()
	var/list/preload = list()
	var/datum/asset_transport/transport = new()

/datum/controller/subsystem/assets/Recover()
	cache = SSassets.cache
	preload = SSassets.preload

/datum/controller/subsystem/assets/proc/apply_configuration(initialize_transport = TRUE)
	var/newtransporttype = /datum/asset_transport
	if(config.asset_transport == "webroot")
		newtransporttype = /datum/asset_transport/webroot

	if(newtransporttype == transport.type)
		return

	var/datum/asset_transport/newtransport = new newtransporttype
	if(newtransport.validate_config())
		transport = newtransport

	if(initialize_transport)
		transport.Initialize(cache)

/datum/controller/subsystem/assets/proc/load_assets()
	for(var/datum/asset/asset_to_load as anything in typesof(/datum/asset))
		if(initial(asset_to_load._abstract))
			continue

		get_asset_datum(type)
