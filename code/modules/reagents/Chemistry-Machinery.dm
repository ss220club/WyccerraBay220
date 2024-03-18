#define CHEMMASTER_OPTIONS_BASE "BASE"
#define CHEMMASTER_OPTIONS_CONDIMENTS "CONDIMENTS"
#define CHEMMASTER_SWITCH_SPRITE_PILL "PILL"
#define CHEMMASTER_SWITCH_SPRITE_BOTTLE "BOTTLE"

/obj/machinery/chem_master
	name = "\improper ChemMaster 3000"
	desc = "This large machine uses a complex filtration system to split, merge, condense, or bottle up any kind of chemical, for all your medicinal* needs."
	density = TRUE
	anchored = TRUE
	icon = 'icons/obj/machines/medical/mixer.dmi'
	icon_state = "mixer"
	layer = BELOW_OBJ_LAYER
	idle_power_usage = 20
	clicksound = "button"
	clickvol = 20
	core_skill = SKILL_CHEMISTRY
	var/obj/item/reagent_containers/beaker = null
	var/obj/item/storage/pill_bottle/loaded_pill_bottle = null

	var/to_beaker = FALSE // If TRUE, reagents will move from buffer -> beaker. If FALSE, reagents will be destroyed when moved from the buffer.
	var/useramount = 30 // Last used amount
	var/pillamount = 10
	var/max_pill_count = 20

	var/bottle_dosage = 60
	var/pill_dosage = 30

	var/bottlesprite = 1
	var/pillsprite = 1
	var/client/has_sprites = list()

	var/sloppy = TRUE // Whether reagents will not be fully purified (sloppy = TRUE) or there will be reagent loss (sloppy = FALSE) on reagent transfer.
	var/production_options = CHEMMASTER_OPTIONS_BASE // Determines what the machine can make from its buffer. A condimaster can't make pills, and so on
	var/reagent_limit = 120
	var/datum/reagent/analyzed_reagent = null // Datum housing the reagent we're currently trying to fetch data about

/obj/machinery/chem_master/New()
	create_reagents(reagent_limit)
	..()

/obj/machinery/chem_master/on_update_icon()
	ClearOverlays()
	if(panel_open)
		AddOverlays("[icon_state]_panel")
	if(is_powered())
		AddOverlays(emissive_appearance(icon, "[icon_state]_lights"))
		AddOverlays("[icon_state]_lights")
	if((beaker) || (loaded_pill_bottle))
		if(!is_powered())
			AddOverlays("[icon_state]_working_nopower")
		else
			AddOverlays(emissive_appearance(icon, "[icon_state]_lights_working"))
			AddOverlays("[icon_state]_lights_working")
			AddOverlays("[icon_state]_working")

/obj/machinery/chem_master/ex_act(severity)
	switch(severity)
		if(EX_ACT_DEVASTATING)
			qdel(src)
			return
		if(EX_ACT_HEAVY)
			if (prob(50))
				qdel(src)
				return

/obj/machinery/chem_master/use_tool(obj/item/B, mob/living/user, list/click_params)
	if(istype(B, /obj/item/reagent_containers/glass) || istype(B, /obj/item/reagent_containers/ivbag))
		if(beaker)
			to_chat(user, "A container is already loaded into the machine.")
			return TRUE
		if(!user.unEquip(B, src))
			return TRUE
		beaker = B
		to_chat(user, SPAN_NOTICE("You add \the [B] to \the [src]!"))
		atom_flags |= ATOM_FLAG_OPEN_CONTAINER
		update_icon()
		return TRUE

	if (istype(B, /obj/item/storage/pill_bottle))
		if(loaded_pill_bottle)
			to_chat(user, "A pill bottle is already loaded into \the [src].")
			return TRUE
		if(!user.unEquip(B, src))
			return TRUE
		loaded_pill_bottle = B
		to_chat(user, SPAN_NOTICE("You add \the [B] into \the [src]'s dispenser slot!"))
		update_icon()
		return TRUE

	return ..()

/obj/machinery/chem_master/proc/eject_beaker(mob/user)
	if(!beaker)
		return
	var/obj/item/reagent_containers/B = beaker
	user.put_in_hands(B)
	beaker = null
	reagents.clear_reagents()
	update_icon()
	atom_flags &= ~ATOM_FLAG_OPEN_CONTAINER

/obj/machinery/chem_master/proc/get_remaining_volume()
	return clamp(reagent_limit - reagents.total_volume, 0, reagent_limit)

/obj/machinery/chem_master/AltClick(mob/user)
	if(CanDefaultInteract(user))
		eject_beaker(user)
		return TRUE
	return ..()

/obj/machinery/chem_master/proc/fetch_contaminants(mob/user, datum/reagents/reagents, datum/reagent/main_reagent)
	. = list()
	for(var/datum/reagent/reagent in reagents.reagent_list)
		if(reagent == main_reagent)
			continue
		if(prob(user.skill_fail_chance(core_skill, 100)))
			. += reagent

/obj/machinery/chem_master/proc/get_chem_info(datum/reagent/reagent, heading = "Chemical Analysis", detailed_blood = 1)
	if(!beaker || !reagent)
		return
	. = list()
	. += "<TITLE>[name]</TITLE>"
	. += "<h2>[heading] - [reagent.name]</h2>"
	if(detailed_blood && istype(reagent, /datum/reagent/blood))
		var/datum/reagent/blood/B = reagent
		. += "<br><b>Species of Origin:</b> [B.data["species"]]<br><b>Blood Type:</b> [B.data["blood_type"]]<br><b>DNA Hash:</b> [B.data["blood_DNA"]]"
	else
		. += "<br>[reagent.description]"
	. = JOINTEXT(.)

/obj/machinery/chem_master/proc/create_bottle(mob/user)
	var/bottle_name = reagents.total_volume ? reagents.get_master_reagent_name() : "glass"
	var/name = sanitizeSafe(input(usr, "Name:", "Name your bottle!", bottle_name) as null|text, MAX_NAME_LEN)
	if (!name)
		return
	var/obj/item/reagent_containers/glass/bottle/P = new/obj/item/reagent_containers/glass/bottle(loc)
	P.SetName("[name] bottle")
	P.icon_state = "bottle-[bottlesprite]"
	reagents.trans_to_obj(P, bottle_dosage)
	P.update_icon()

/obj/machinery/chem_master/interface_interact(mob/user)
	tgui_interact(user)
	return TRUE

/obj/machinery/chem_master/tgui_state(mob/user)
	return GLOB.default_state

/obj/machinery/chem_master/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ChemMaster", name)
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/chem_master/ui_assets(mob/user)
	return list(get_asset_datum(/datum/asset/spritesheet/chem_master))

/obj/machinery/chem_master/tgui_data(mob/user)
	var/list/data = list()

	data["pillSprite"] = pillsprite
	data["bottleSprite"] = bottlesprite
	data["isSloppy"] = sloppy
	data["loadedContainer"] = beaker
	data["isTransferringToBeaker"] = to_beaker
	data["productionOptions"] = production_options
	data["pillDosage"] = pill_dosage
	data["bottleDosage"] = bottle_dosage

	if(analyzed_reagent)
		data["analyzedReagent"] = analyzed_reagent
		data["analyzedData"] = get_chem_info(analyzed_reagent)

	if(loaded_pill_bottle)
		data["loadedPillBottle"] = loaded_pill_bottle
		data["pillBottleBlurb"] = "Eject Pill Bottle \[[length(loaded_pill_bottle.contents)]/[loaded_pill_bottle.max_storage_space]\]"

	data["containerChemicals"] = list()
	if(beaker && beaker.reagents && beaker.reagents.reagent_list)
		for(var/datum/reagent/R in beaker.reagents.reagent_list)
			var/reagent_data = list()
			reagent_data["name"] = R.name
			reagent_data["desc"] = R.description
			reagent_data["volume"] = R.volume
			reagent_data["ref"] = "\ref[R]"
			data["containerChemicals"] += list(reagent_data)

	data["bufferChemicals"] = list()
	if (reagents && reagents.reagent_list)
		for (var/datum/reagent/R in reagents.reagent_list)
			var/reagent_data = list()
			reagent_data["name"] = R.name
			reagent_data["desc"] = R.description
			reagent_data["volume"] = R.volume
			reagent_data["ref"] = "\ref[R]"
			data["bufferChemicals"] += list(reagent_data)

	return data

/obj/machinery/chem_master/tgui_static_data(mob/user)
	var/list/static_data = list()

	var/pill_styles = list()
	for(var/i in 1 to MAX_PILL_SPRITE)
		pill_styles += list(list(
			"id" = i,
			"sprite" = "pill[i]",
		))
	static_data["pillSprites"] = pill_styles

	var/bottle_styles = list()
	var/bottle_style_index = 0
	for(var/style in BOTTLE_SPRITES)
		bottle_style_index++
		bottle_styles += list(list(
			"id" = bottle_style_index,
			"sprite" = "[style]",
		))
	static_data["bottleSprites"] = bottle_styles

	return static_data

/obj/machinery/chem_master/tgui_act(action, params)
	if(..())
		return

	var/datum/reagents/R = beaker.reagents
	switch(action)
		if("ejectPillBottle")
			if(!loaded_pill_bottle)
				return FALSE
			if(Adjacent(usr))
				usr.put_in_hands(loaded_pill_bottle)
			else
				loaded_pill_bottle.dropInto(loc)
			loaded_pill_bottle = null
			return TRUE
		if("analyze")
			var/datum/reagent/reagent = locate(params["name"]) in R.reagent_list
			if(!reagent)
				reagent = locate(params["name"]) in reagents.reagent_list
			if(reagent)
				analyzed_reagent = reagent
			return TRUE
		if("add")
			var/datum/reagent/their_reagent = locate(params["reagent"]) in R.reagent_list
			if(!their_reagent)
				return FALSE
			var/mult = 1
			var/amount = clamp((text2num(params["amount"])), 0, get_remaining_volume())
			if(sloppy)
				var/contaminants = fetch_contaminants(usr, R, their_reagent)
				for(var/datum/reagent/reagent in contaminants)
					R.trans_type_to(src, reagent.type, round(rand() * amount / 5, 0.1))
			else
				mult -= 0.4 * (SKILL_MAX - usr.get_skill_value(core_skill))/(SKILL_MAX-SKILL_MIN) //10% loss per skill level down from max
			R.trans_type_to(src, their_reagent.type, amount, mult)
			return TRUE
		if("remove")
			var/datum/reagent/my_reagents = locate(params["reagent"]) in reagents.reagent_list
			if(!my_reagents)
				return FALSE
			var/amount = clamp((text2num(params["amount"])), 0, 200)
			var/contaminants = fetch_contaminants(usr, reagents, my_reagents)
			if(to_beaker)
				reagents.trans_type_to(beaker, my_reagents.type, amount)
				for(var/datum/reagent/reagent in contaminants)
					reagents.trans_type_to(beaker, reagent.type, round(rand()*amount, 0.1))
					return TRUE
			else
				reagents.remove_reagent(my_reagents.type, amount)
				for(var/datum/reagent/reagent in contaminants)
					reagents.remove_reagent(reagent.type, round(rand()*amount, 0.1))
					return TRUE
		if("eject")
			eject_beaker(usr)
			return TRUE
		if("toggle")
			to_beaker = !to_beaker
			return TRUE
		if("toggleSloppy")
			sloppy = !sloppy
			return TRUE
		if("pillDosage")
			var/initial_dosage = initial(pill_dosage)
			var/new_dosage = params["newDosage"]
			if(!new_dosage)
				return FALSE
			new_dosage = clamp(new_dosage, 0, initial_dosage)
			pill_dosage = new_dosage
			return TRUE
		if("bottleDosage")
			var/initial_dosage = initial(bottle_dosage)
			var/new_dosage = params["newDosage"]
			if(!new_dosage)
				return FALSE
			new_dosage = clamp(new_dosage, 0, initial_dosage)
			bottle_dosage = new_dosage
			return TRUE
		if("createPill")
			var/count = 1
			if(reagents.total_volume/count < 1)
				return TRUE
			if(params["createpill_multiple"])
				count = tgui_input_number(usr, "Введите сколько таблеток сделать.", src.name, pillamount, max_pill_count, 1)
				count = clamp(count, 1, max_pill_count)
			if(reagents.total_volume / count < 1)
				return TRUE
			var/amount_per_pill = reagents.total_volume/count
			if(amount_per_pill > 60) amount_per_pill = 60
			var/pill_name = tgui_input_text(usr, "Назовите таблетку.", src.name, "[reagents.get_master_reagent_name()] ([amount_per_pill] units)", MAX_NAME_LEN)
			if(reagents.total_volume / count < 1)
				return TRUE
			while(count-- && count >= 0)
				var/obj/item/reagent_containers/pill/P = new/obj/item/reagent_containers/pill(get_turf(src))
				if(!pill_name)
					pill_name = reagents.get_master_reagent_name()
				P.name = "[pill_name]"
				P.pixel_x = rand(-7, 7)
				P.pixel_y = rand(-7, 7)
				P.icon_state = "pill-[pillsprite]"
				reagents.trans_to_obj(P,amount_per_pill)
				if(!loaded_pill_bottle)
					continue
				if(length(loaded_pill_bottle.contents) < loaded_pill_bottle.max_storage_space)
					P.forceMove(loaded_pill_bottle)
			return TRUE
		if("createBottle")
			create_bottle(usr)
			return TRUE
		if("changePillStyle")
			var/new_style = params["style"]
			if(isnull(new_style))
				return FALSE
			pillsprite = new_style
			return TRUE
		if("changeBottleStyle")
			var/new_style = params["style"]
			if(isnull(new_style))
				return FALSE
			bottlesprite = new_style
			return TRUE

/obj/machinery/chem_master/condimaster
	name = "\improper CondiMaster 3000"
	desc = "A machine pre-supplied with plastic condiment containers to bottle up reagents for use with foods."
	core_skill = SKILL_COOKING
	production_options = CHEMMASTER_OPTIONS_CONDIMENTS

/obj/machinery/chem_master/condimaster/get_chem_info(datum/reagent/reagent)
	return ..(reagent, "Condiment Info", 0)

/obj/machinery/chem_master/condimaster/create_bottle(mob/user)
	var/obj/item/reagent_containers/food/condiment/P = new/obj/item/reagent_containers/food/condiment(loc)
	reagents.trans_to_obj(P, 50)

#undef CHEMMASTER_OPTIONS_BASE
#undef CHEMMASTER_OPTIONS_CONDIMENTS

#undef CHEMMASTER_SWITCH_SPRITE_PILL
#undef CHEMMASTER_SWITCH_SPRITE_BOTTLE
