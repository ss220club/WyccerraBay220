/datum/unit_test/icon_test
	name = "ICON STATE template"
	template = /datum/unit_test/icon_test

/datum/unit_test/icon_test/robots_shall_have_eyes_for_each_state
	name = "ICON STATE - Robot shall have eyes for each icon state"
	var/list/excepted_icon_states_ = list(
		"droid-combat-roll",
		"droid-combat-shield"
	)

/datum/unit_test/icon_test/robots_shall_have_eyes_for_each_state/start_test()
	var/missing_states = 0
	var/list/valid_icons = list('icons/mob/robots.dmi', 'icons/mob/robots_drones.dmi', 'icons/mob/robots_flying.dmi')
	var/list/valid_states = ICON_STATES(valid_icons)

	for(var/icon_state in valid_states)
		if(icon_state in excepted_icon_states_)
			continue

		if(text_starts_with(icon_state, "eyes-"))
			continue

		if(findtext(icon_state, "openpanel"))
			continue

		var/eye_icon_state = "eyes-[icon_state]"
		if(!ANY_ICON_HAS_STATE(valid_icons, eye_icon_state))
			log_unit_test("Eye icon state [eye_icon_state] is missing.")
			missing_states++

	if(missing_states)
		fail("[missing_states] eye icon state\s [missing_states == 1 ? "is" : "are"] missing.")
		var/list/difference = uniquemergelist(valid_states, valid_states)
		if(length(difference))
			log_unit_test("[ascii_yellow]---  DEBUG  --- ICON STATES AT START: " + jointext(valid_states, ",") + "[ascii_reset]")
			log_unit_test("[ascii_yellow]---  DEBUG  --- ICON STATES AT END: "   + jointext(valid_states, ",") + "[ascii_reset]")
			log_unit_test("[ascii_yellow]---  DEBUG  --- UNIQUE TO EACH LIST: " + jointext(difference, ",") + "[ascii_reset]")
	else
		pass("All related eye icon states exists.")
	return 1

/datum/unit_test/icon_test/sprite_accessories_shall_have_existing_icon_states
	name = "ICON STATE - Sprite accessories shall have existing icon states"

/datum/unit_test/icon_test/sprite_accessories_shall_have_existing_icon_states/start_test()
	var/sprite_accessory_subtypes = list(
		/datum/sprite_accessory/hair,
		/datum/sprite_accessory/facial_hair
	)

	var/list/failed_sprite_accessories = list()
	var/duplicates_found = FALSE

	for(var/sprite_accessory_main_type in sprite_accessory_subtypes)
		var/sprite_accessories_by_name = list()
		for(var/sprite_accessory_type in subtypesof(sprite_accessory_main_type))
			var/failed = FALSE
			var/datum/sprite_accessory/sat = sprite_accessory_type
			if (is_abstract(sat))
				continue
			var/sat_name = initial(sat.name)
			if(sat_name)
				group_by(sprite_accessories_by_name, sat_name, sat)
			else
				failed = TRUE
				log_bad("[sat] - Did not have a name set.")

			var/sat_icon = initial(sat.icon)
			if(sat_icon)
				var/sat_icon_state = initial(sat.icon_state)
				if(sat_icon_state)
					sat_icon_state = "[sat_icon_state]_s"
					if(!ICON_HAS_STATE(sat_icon, sat_icon_state))
						failed = TRUE
						log_bad("[sat] - \"[sat_icon_state]\" did not exist in '[sat_icon]'.")
				else
					failed = TRUE
					log_bad("[sat] - Did not have an icon state set.")
			else
				failed = TRUE
				log_bad("[sat] - Did not have an icon set.")

			if(failed)
				failed_sprite_accessories += sat

		if(number_of_issues(sprite_accessories_by_name, "Sprite Accessory Names"))
			duplicates_found = TRUE

	if(length(failed_sprite_accessories) || duplicates_found)
		fail("One or more sprite accessory issues detected.")
	else
		pass("All sprite accessories were valid.")

	return 1

/datum/unit_test/icon_test/posters_shall_have_icon_states
	name = "ICON STATE - Posters Shall Have Icon States"

/datum/unit_test/icon_test/posters_shall_have_icon_states/start_test()
	var/list/invalid_posters = list()

	for(var/poster_type in subtypesof(/singleton/poster))
		if (is_abstract(poster_type))
			continue
		var/singleton/poster/P = GET_SINGLETON(poster_type)

		if(!ICON_HAS_STATE('icons/obj/structures/contraband.dmi', P.icon_state) \
			&& !ICON_HAS_STATE('mods/nyc_posters/icons/nyc_posters.dmi', P.icon_state) \
			&& !ICON_HAS_STATE('mods/tajara/icons/posters.dmi', P.icon_state) \
		)
			invalid_posters += poster_type

	if(length(invalid_posters))
		fail("/singleton/poster with missing icon states: [english_list(invalid_posters)]")
	else
		pass("All /singleton/poster subtypes have valid icon states.")
	return 1

/datum/unit_test/icon_test/item_modifiers_shall_have_icon_states
	name = "ICON STATE - Item Modifiers Shall Have Icon Sates"
	var/list/icon_states_by_type

/datum/unit_test/icon_test/item_modifiers_shall_have_icon_states/start_test()
	var/list/bad_modifiers = list()
	var/item_modifiers = list_values(Singletons.GetMap(/singleton/item_modifier))

	for(var/im in item_modifiers)
		var/singleton/item_modifier/item_modifier = im
		for(var/type_setup_type in item_modifier.type_setups)
			var/list/type_setup = item_modifier.type_setups[type_setup_type]
			var/obj/item/item_type = type_setup_type
			if(!ICON_HAS_STATE(initial(item_type.icon), type_setup["icon_state"]))
				bad_modifiers += type_setup_type

	if(length(bad_modifiers))
		fail("Item modifiers with missing icon states: [english_list(bad_modifiers)]")
	else
		pass("All item modifiers have valid icon states.")
	return 1

/datum/unit_test/icon_test/random_spawners_shall_have_icon_states
	name = "ICON STATE - Random Spawners Shall Have Icon States"

/datum/unit_test/icon_test/random_spawners_shall_have_icon_states/start_test()
	var/list/invalid_spawners = list()
	for(var/random_type in typesof(/obj/random))
		var/obj/random/R = random_type
		var/icon = initial(R.icon)
		var/icon_state = initial(R.icon_state) || ""

		if(!ICON_HAS_STATE(icon, icon_state))
			invalid_spawners += random_type

	if(length(invalid_spawners))
		fail("[length(invalid_spawners)] /obj/random type\s with missing icon states: [json_encode(invalid_spawners)]")
	else
		pass("All /obj/random types have valid icon states.")
	return 1
