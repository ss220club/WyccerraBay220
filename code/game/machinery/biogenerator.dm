/// The base amount of plants that can be stored before taking our matter bin into account.
#define BASE_MAX_STORABLE_PLANTS 40

/obj/machinery/biogenerator
	name = "biogenerator"
	desc = "Converts plants into biomass, which can be used to construct useful items."
	icon = 'icons/obj/machines/biogenerator.dmi'
	icon_state = "biogen"
	density = TRUE
	anchored = TRUE
	idle_power_usage = 40
	base_type = /obj/machinery/biogenerator
	construct_state = /singleton/machine_construction/default/panel_closed
	uncreated_component_parts = null
	stat_immune = 0
	machine_name = "biogenerator"
	machine_desc = "Processes fruits, veggies, and other produce into raw biomatter that can be converted into food products and leather items."
	/// Is the biogenerator curretly grinding up plants?
	var/processing = FALSE
	/// Container inside biogenerator
	var/obj/item/reagent_containers/glass/beaker
	/// The amount of biomass stored in the machine.
	var/biomass = 0
	/// Used to modify the cost of producing items. A higher number means cheaper costs.
	var/efficiency = 1
	/// Used to modify how much biomass is produced by grinding plants. A higher number means more biomass.
	var/productivity = 1
	/// A list of plants currently stored plants in the biogenerator.
	var/list/stored_plants = list()
	/// The maximum amount of plants the biogenerator can store.
	var/max_storable_plants = BASE_MAX_STORABLE_PLANTS
	/// List of categories, and items with cost inside it, available to produce.
	var/list/products = list(
		"Food" = list(
			/obj/item/reagent_containers/food/drinks/small_milk = 30,
			/obj/item/reagent_containers/food/drinks/milk = 50,
			/obj/item/reagent_containers/food/snacks/meat/syntiflesh = 50,
			/obj/item/storage/fancy/egg_box/full = 300),
		"Nutrients" = list(
			/obj/item/reagent_containers/glass/bottle/eznutrient = 60,
			/obj/item/reagent_containers/glass/bottle/left4zed = 120,
			/obj/item/reagent_containers/glass/bottle/robustharvest = 120),
		"Leather" = list(
			/obj/item/storage/wallet = 100,
			/obj/item/stack/material/leather = 100,
			/obj/item/clothing/gloves/thick/botany = 250,
			/obj/item/storage/belt/utility = 300,
			/obj/item/storage/backpack/satchel = 400,
			/obj/item/storage/bag/cash = 400,
			/obj/item/clothing/shoes/workboots = 400,
			/obj/item/clothing/shoes/leather = 400,
			/obj/item/clothing/shoes/dress = 400,
			/obj/item/clothing/suit/leathercoat = 500,
			/obj/item/clothing/suit/storage/toggle/brown_jacket = 500,
			/obj/item/clothing/suit/storage/toggle/bomber = 500,
			/obj/item/clothing/suit/storage/hooded/wintercoat = 500))

/obj/machinery/biogenerator/New()
	. = ..()
	create_reagents(1000)
	beaker = new /obj/item/reagent_containers/glass/bottle(src)

/obj/machinery/biogenerator/Destroy()
	. = ..()
	QDEL_NULL(beaker)
	QDEL_NULL_LIST(stored_plants)

/obj/machinery/biogenerator/on_reagent_change()			//When the reagents change, change the icon as well.
	update_icon()

/obj/machinery/biogenerator/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if(is_powered())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")
	else if(processing)
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights_working"))
		AddOverlays("[icon_state]_lights_working")
		AddOverlays("biogen_stand")
	else
		AddOverlays("biogen_stand")
	return

/obj/machinery/biogenerator/components_are_accessible(path)
	return !processing && ..()

/obj/machinery/biogenerator/cannot_transition_to(state_path)
	if(processing)
		return SPAN_NOTICE("You must turn \the [src] off first.")
	return ..()

/obj/machinery/biogenerator/examine(mob/user)
	. = ..()
	if(processing)
		to_chat(user, SPAN_NOTICE("\The [src] is currently processing."))
	if(stored_plants >= max_storable_plants)
		to_chat(user, SPAN_NOTICE("\The [src] is full!"))

/obj/machinery/biogenerator/use_tool(obj/item/O, mob/living/user, list/click_params)
	. = ..()
	if(processing)
		to_chat(user, "<span class='warning'>[src] is currently processing.</span>")
		return

	else if(istype(O, /obj/item/reagent_containers/glass))
		if(!beaker && user.unEquip(O, src))
			beaker = O
			update_icon()
			SStgui.update_uis(src)
			return TRUE

	else if(istype(O, /obj/item/storage/plants))
		if(length(stored_plants) >= max_storable_plants)
			to_chat(user, "<span class='warning'>[src] can't hold any more plants!</span>")
			return

		var/obj/item/storage/plants/PB = O
		for(var/obj/item/reagent_containers/food/snacks/grown/G in PB.contents)
			if(length(stored_plants) >= max_storable_plants)
				break
			PB.remove_from_storage(G, src)
			stored_plants += G

		if(length(stored_plants) < max_storable_plants)
			to_chat(user, "<span class='info'>You empty [PB] into [src].</span>")
		else
			to_chat(user, "<span class='info'>You fill [src] to its capacity.</span>")

		SStgui.update_uis(src)
		return TRUE

	else if(istype(O, /obj/item/reagent_containers/food/snacks/grown))
		if(length(stored_plants) >= max_storable_plants)
			to_chat(user, "<span class='warning'>[src] can't hold any more plants!</span>")
			return
		if(!user.unEquip(O))
			return

		O.forceMove(src)
		stored_plants += O
		to_chat(user, "<span class='info'>You put [O] in [src].</span>")
		SStgui.update_uis(src)
		return TRUE
	else
		to_chat(user, SPAN_NOTICE("You cannot put this in \the [src]."))

/obj/machinery/biogenerator/interface_interact(mob/user)
	tgui_interact(user)
	return TRUE

/obj/machinery/biogenerator/tgui_state(mob/user)
	return GLOB.default_state

/obj/machinery/biogenerator/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Biogenerator")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/biogenerator/tgui_data(mob/user)
	var/list/data = list()

	data["processing"] = processing
	data["biomass"] = biomass
	data["storedPlants"] = length(stored_plants) ? TRUE : FALSE
	data["container"] = beaker ? TRUE : FALSE
	data["containerContent"] = beaker.reagents.total_volume
	data["containerMaxContent"] = beaker.reagents.maximum_volume

	return data

/obj/machinery/biogenerator/tgui_static_data(mob/user)
	var/list/static_data = list()

	var/list/listed_types = list()
	for(var/c_type = 1 to length(products))
		var/list/current_content = products[products[c_type]]
		var/list/listed_products = list()
		for(var/c_product = 1 to length(current_content))
			var/atom/thing = current_content[c_product]
			listed_products += list(list(
				"product_index" = c_product,
				"name" = initial(thing.name),
				"cost" = current_content[current_content[c_product]]
				))
		listed_types += list(list(
			"type_name" = products[c_type],
			"products" = listed_products
			))
	static_data["types"] = listed_types

	return static_data

/obj/machinery/biogenerator/tgui_act(action, params)
	if(..())
		return
	. = TRUE

	switch(action)
		if("activate")
			activate()
			return TRUE
		if("detach")
			detach_container()
			return TRUE
		if("eject_plants")
			eject_plants()
			return TRUE
		if("create")
			var/type = params["type"]
			var/product_index = text2num(params["product_index"])
			if(isnull(products[type]))
				return FALSE
			var/list/sub_products = products[type]
			if(product_index < 1 || product_index > length(sub_products))
				return TRUE
			create_product(type, sub_products[product_index])
			return TRUE

/obj/machinery/biogenerator/proc/activate()
	processing = TRUE
	SStgui.update_uis(src)
	update_icon()

	var/plants_processed = length(stored_plants)
	for(var/obj/item/reagent_containers/food/snacks/grown/plant as anything in stored_plants)
		var/plant_biomass = plant.reagents.get_reagent_amount(/datum/reagent/nutriment)
		biomass += max(plant_biomass, 0.1) * 10 * productivity
		qdel(plant)

	stored_plants.Cut()
	playsound(loc, 'sound/machines/blender.ogg', 50, 1)
	use_power_oneoff(plants_processed * 50)
	addtimer(CALLBACK(src, PROC_REF(end_processing)), (plants_processed * 5) / productivity)

/obj/machinery/biogenerator/proc/end_processing()
	processing = FALSE
	SStgui.update_uis(src)
	update_icon()

/obj/machinery/biogenerator/proc/eject_plants()
	for(var/obj/item/reagent_containers/food/snacks/grown/plant as anything in stored_plants)
		plant.forceMove(get_turf(src))
	stored_plants.Cut()
	SStgui.update_uis(src)

/obj/machinery/biogenerator/proc/detach_container()
	if(!beaker)
		return
	beaker.forceMove(get_turf(src))
	beaker = null
	update_icon()

/obj/machinery/biogenerator/proc/create_product(type, path)
	processing = TRUE
	SStgui.update_uis(src)
	var/cost = products[type][path]
	cost = round(cost / efficiency)
	biomass -= cost
	update_icon()
	addtimer(CALLBACK(src, PROC_REF(drop_product), path), 3 SECONDS)

/obj/machinery/biogenerator/proc/drop_product(path)
	var/atom/movable/result = new path
	result.dropInto(loc)
	processing = FALSE
	SStgui.update_uis(src)
	update_icon()

/obj/machinery/biogenerator/RefreshParts()
	..()
	efficiency = clamp(total_component_rating_of_type(/obj/item/stock_parts/manipulator), 1, 10)
	productivity = clamp(total_component_rating_of_type(/obj/item/stock_parts/matter_bin), 1, 10)

#undef BASE_MAX_STORABLE_PLANTS
