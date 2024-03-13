#define CYBORG_POWER_USAGE_MULTIPLIER 2.5 // Multiplier for amount of power cyborgs use.

/mob/living/silicon/robot
	name = "Cyborg"
	real_name = "Cyborg"
	icon = 'icons/mob/robots.dmi'
	icon_state = "robot"
	maxHealth = 300
	health = 300

	mob_bump_flag = ROBOT
	mob_swap_flags = ROBOT|MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = ~HEAVY //trundle trundle
	skillset = /datum/skillset/silicon/robot

	blocks_emissive = EMISSIVE_BLOCK_NONE

	var/lights_on = FALSE
	var/used_power_this_tick = 0
	var/power_efficiency = 1
	var/sight_mode = 0
	var/custom_name = ""
	var/custom_sprite = FALSE
	var/crisis //Admin-settable for combat module use.
	var/crisis_override = FALSE
	var/integrated_light_power = 0.75
	var/datum/wires/robot/wires
	var/module_category = ROBOT_MODULE_TYPE_GROUNDED
	var/dismantle_type = /obj/item/robot_parts/robot_suit

//Icon stuff

	var/static/list/eye_overlays
	var/icontype 				//Persistent icontype tracking allows for cleaner icon updates
	var/module_sprites[0] 		//Used to store the associations between sprite names and sprite index.
	var/icon_selected = 1		//If icon selection has been completed yet
	var/icon_selection_tries = 0//Remaining attempts to select icon before a selection is forced

//Hud stuff

	var/obj/screen/inv1 = null
	var/obj/screen/inv2 = null
	var/obj/screen/inv3 = null

	var/shown_robot_modules = 0 //Used to determine whether they have the module menu shown or not
	var/obj/screen/robot_modules_background

//3 Modules can be activated at any one time.
	var/obj/item/robot_module/module = null
	var/obj/item/module_active
	var/obj/item/module_state_1
	var/obj/item/module_state_2
	var/obj/item/module_state_3

	silicon_camera = /obj/item/device/camera/siliconcam/robot_camera
	silicon_radio = /obj/item/device/radio/borg

	var/mob/living/silicon/ai/connected_ai = null
	var/obj/item/cell/cell = /obj/item/cell/high

	var/cell_emp_mult = 2.5

	// Components are basically robot organs.
	var/list/components = list()

	var/obj/item/device/mmi/mmi = null

	var/obj/item/stock_parts/matter_bin/storage = null

	var/opened = FALSE
	var/emagged = FALSE
	var/wiresexposed = FALSE
	var/locked = TRUE
	var/has_power = TRUE
	var/spawn_module = null

	var/spawn_sound = 'sound/voice/liveagain.ogg'
	var/pitch_toggle = TRUE
	var/list/req_access = list(access_robotics)
	var/ident = 0
	var/modtype = "Default"
	var/datum/effect/spark_spread/spark_system //So they can initialize sparks whenever/N
	var/lawupdate = TRUE //Cyborgs will sync their laws with their AI by default
	var/lockcharge //If a robot is locked down
	var/scrambledcodes = FALSE // Used to determine if a borg shows up on the robotics console.  Setting to one hides them.
	var/tracking_entities = 0 //The number of known entities currently accessing the internal camera
	var/braintype = "Drone"
	var/intenselight = FALSE	// Whether cyborg's integrated light was upgraded
	var/vtec = FALSE
	var/flash_protected = FALSE

	var/list/robot_verbs_default = list(
		/mob/living/silicon/robot/proc/sensor_mode,
		/mob/living/silicon/robot/proc/robot_checklaws
	)

/mob/living/silicon/robot/Initialize()
	. = ..()
	spark_system = new /datum/effect/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

	add_language(LANGUAGE_ROBOT_GLOBAL, 1)
	add_language(LANGUAGE_EAL, 1)

	wires = new(src)

	robot_modules_background = new()
	robot_modules_background.icon_state = "block"
	ident = random_id(/mob/living/silicon/robot, 1, 999)
	module_sprites["Basic"] = "robot"
	icontype = "Basic"
	updatename(modtype)
	update_icon()
	init()
	initialize_components()

	for(var/V in components) if(V != "power cell")
		var/datum/robot_component/C = components[V]
		C.installed = 1
		C.wrapped = new C.external_type

	if(ispath(cell))
		cell = new cell(src)

	if(cell)
		var/datum/robot_component/cell_component = components["power cell"]
		cell_component.wrapped = cell
		cell_component.installed = 1

	add_robot_verbs()

	hud_list[HEALTH_HUD]      = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[STATUS_HUD]      = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[LIFE_HUD]        = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudhealth100")
	hud_list[ID_HUD]          = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[WANTED_HUD]      = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPLOYAL_HUD]    = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPCHEM_HUD]     = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[IMPTRACK_HUD]    = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")
	hud_list[SPECIALROLE_HUD] = new /image/hud_overlay('icons/mob/hud.dmi', src, "hudblank")

	AddMovementHandler(/datum/movement_handler/robot/use_power, /datum/movement_handler/mob/space)

/mob/living/silicon/robot/proc/recalculate_synth_capacities()
	if(!module || !module.synths)
		return
	var/mult = 1
	if(storage)
		mult += storage.rating
	for(var/datum/matter_synth/M in module.synths)
		M.set_multiplier(mult)

/mob/living/silicon/robot/proc/init()
	if(ispath(module))
		new module(src)
	if(lawupdate)
		var/new_ai = select_active_ai_with_fewest_borgs(get_z(src))
		if(new_ai)
			lawupdate = TRUE
			connect_to_ai(new_ai)
		else
			lawupdate = FALSE
	playsound(loc, spawn_sound, 75, pitch_toggle)

/mob/living/silicon/robot/fully_replace_character_name(pickedName as text)
	custom_name = pickedName
	updatename()

/mob/living/silicon/robot/proc/sync()
	if(lawupdate && connected_ai)
		lawsync()
		photosync()

/mob/living/silicon/robot/drain_power(drain_check, surge, amount = 0)

	if(drain_check)
		return 1

	if(!cell || !cell.charge)
		return 0

	// Actual amount to drain from cell, using CELLRATE
	var/cell_amount = amount * CELLRATE

	if(cell.charge > cell_amount)
		// Spam Protection
		if(prob(10))
			to_chat(src, SPAN_DANGER("Warning: Unauthorized access through power channel [rand(11,29)] detected!"))
		cell.use(cell_amount)
		return amount
	return 0

//If there's an MMI in the robot, have it ejected when the mob goes away. --NEO
//Improved /N
/mob/living/silicon/robot/Destroy()
	if(mmi)//Safety for when a cyborg gets dust()ed. Or there is no MMI inside.
		if(mind)
			mmi.dropInto(loc)
			if(mmi.brainmob)
				mind.transfer_to(mmi.brainmob)
			else
				to_chat(src, SPAN_DANGER("Oops! Something went very wrong, your MMI was unable to receive your mind. You have been ghosted. Please make a bug report so we can fix this bug."))
				ghostize()
				//ERROR("A borg has been destroyed, but its MMI lacked a brainmob, so the mind could not be transferred. Player: [ckey].")
			mmi = null
		else
			QDEL_NULL(mmi)
	if(connected_ai)
		connected_ai.connected_robots -= src
	connected_ai = null
	QDEL_NULL(module)
	QDEL_NULL(wires)
	. = ..()

/mob/living/silicon/robot/proc/set_module_sprites(list/new_sprites)
	if(new_sprites && length(new_sprites))
		module_sprites = new_sprites.Copy()
		//Custom_sprite check and entry

		if (custom_sprite)
			if(ICON_HAS_STATE(CUSTOM_ITEM_SYNTH, "[ckey]-[modtype]"))
				module_sprites["Custom"] = "[src.ckey]-[modtype]"
				icon = CUSTOM_ITEM_SYNTH
				icontype = "Custom"
			else
				icontype = module_sprites[1]
				icon = 'icons/mob/robots.dmi'
				to_chat(src, SPAN_WARNING("Custom Sprite Sheet does not contain a valid icon_state for [ckey]-[modtype]"))
		else
			icontype = module_sprites[1]
		icon_state = module_sprites[icontype]
	update_icon()
	return module_sprites

/mob/living/silicon/robot/proc/reset_module(suppress_alert = null)
	// Clear hands and module icon.
	uneq_all()
	if(shown_robot_modules)
		hud_used.toggle_show_robot_modules()
	modtype = initial(modtype)
	if(hands)
		hands.icon_state = initial(hands.icon_state)
	// If the robot had a module and this wasn't an uncertified change, let the AI know.
	if(module)
		if (!suppress_alert)
			notify_ai(ROBOT_NOTIFICATION_MODULE_RESET, module.name)
		// Delete the module.
		module.Reset(src)
		QDEL_NULL(module)
	updatename("Default")

/mob/living/silicon/robot/proc/pick_module(override)
	if(module && !override)
		return

	var/singleton/security_state/security_state = GET_SINGLETON(GLOB.using_map.security_state)
	var/is_crisis_mode = crisis_override || (crisis && security_state.current_security_level_is_same_or_higher_than(security_state.high_security_level))
	var/list/robot_modules = SSrobots.get_available_modules(module_category, is_crisis_mode, override)

	if(!override)
		if(is_crisis_mode)
			to_chat(src, SPAN_WARNING("Crisis mode active. Additional modules available."))
		modtype = input("Please select a module!", "Robot module", null, null) as null|anything in robot_modules
	else
		if(module)
			QDEL_NULL(module)
		modtype = override

	if(module || !modtype)
		return

	var/module_type = robot_modules[modtype]
	if(!module_type)
		to_chat(src, SPAN_WARNING("You are unable to select a module."))
		return

	new module_type(src)

	if(hands)
		hands.icon_state = lowertext(modtype)
	updatename()
	recalculate_synth_capacities()
	if(module)
		notify_ai(ROBOT_NOTIFICATION_NEW_MODULE, module.name)

/mob/living/silicon/robot/get_cell()
	return cell

/mob/living/silicon/robot/proc/updatename(prefix as text)
	if(prefix)
		modtype = prefix

	if(istype(mmi, /obj/item/organ/internal/posibrain))
		braintype = "Robot"
	else if(istype(mmi, /obj/item/device/mmi/digital/robot))
		braintype = "Drone"
	else
		braintype = "Cyborg"

	var/changed_name = ""
	if(custom_name)
		changed_name = custom_name
		notify_ai(ROBOT_NOTIFICATION_NEW_NAME, real_name, changed_name)
	else
		changed_name = "[modtype] [braintype]-[num2text(ident)]"

	create_or_rename_email(changed_name, "root.rt")
	real_name = changed_name
	name = real_name
	if(mind)
		mind.name = changed_name

	if(!custom_sprite) //Check for custom sprite
		set_custom_sprite()

	//Flavour text.
	if(client)
		var/module_flavour = client.prefs.flavour_texts_robot[modtype]
		if(module_flavour)
			flavor_text = module_flavour
		else
			flavor_text = client.prefs.flavour_texts_robot["Default"]

/mob/living/silicon/robot/verb/Namepick()
	set category = "Silicon Commands"
	if(custom_name)
		return 0

	spawn(0)
		var/newname
		newname = sanitizeName(input(src,"You are a robot. Enter a name, or leave blank for the default name.", "Name change","") as text, MAX_NAME_LEN, allow_numbers = 1)
		if (newname)
			custom_name = newname

		updatename()
		update_icon()

/mob/living/silicon/robot/verb/toggle_panel_lock()
	set name = "Toggle Panel Lock"
	set category = "Silicon Commands"
	if(!opened && has_power && do_after(usr, 6 SECONDS, do_flags = DO_DEFAULT | DO_USER_UNIQUE_ACT) && !opened && has_power)
		to_chat(src, "You [locked ? "un" : ""]lock your panel.")
		locked = !locked

/mob/living/silicon/robot/proc/self_diagnosis()
	if(!is_component_functioning("diagnosis unit"))
		return null

	var/dat = "<HEAD><TITLE>[src.name] Self-Diagnosis Report</TITLE></HEAD><BODY>\n"
	for (var/V in components)
		var/datum/robot_component/C = components[V]
		dat += "<b>[C.name]</b><br><table><tr><td>Brute Damage:</td><td>[C.brute_damage]</td></tr><tr><td>Electronics Damage:</td><td>[C.electronics_damage]</td></tr><tr><td>Powered:</td><td>[(!C.idle_usage || C.is_powered()) ? "Yes" : "No"]</td></tr><tr><td>Toggled:</td><td>[ C.toggled ? "Yes" : "No"]</td></table><br>"

	return dat

/mob/living/silicon/robot/verb/toggle_lights()
	set category = "Silicon Commands"
	set name = "Toggle Lights"

	if(stat == DEAD)
		return

	lights_on = !lights_on
	to_chat(usr, "You [lights_on ? "enable" : "disable"] your integrated light.")
	update_robot_light()

/mob/living/silicon/robot/verb/self_diagnosis_verb()
	set category = "Silicon Commands"
	set name = "Self Diagnosis"

	if(!is_component_functioning("diagnosis unit"))
		to_chat(src, SPAN_WARNING("Your self-diagnosis component isn't functioning."))
		return

	var/datum/robot_component/CO = get_component("diagnosis unit")
	if (!cell_use_power(CO.active_usage))
		to_chat(src, SPAN_WARNING("Low Power."))
		return
	var/dat = self_diagnosis()
	show_browser(src, dat, "window=robotdiagnosis")


/mob/living/silicon/robot/verb/toggle_component()
	set category = "Silicon Commands"
	set name = "Toggle Component"
	set desc = "Toggle a component, conserving power."

	var/list/installed_components = list()
	for(var/V in components)
		if(V == "power cell") continue
		var/datum/robot_component/C = components[V]
		if(C.installed)
			installed_components += V

	var/toggle = input(src, "Which component do you want to toggle?", "Toggle Component") as null|anything in installed_components
	if(!toggle)
		return

	var/datum/robot_component/C = components[toggle]
	if(C.toggled)
		C.toggled = 0
		to_chat(src, SPAN_WARNING("You disable [C.name]."))
	else
		C.toggled = 1
		to_chat(src, SPAN_WARNING("You enable [C.name]."))
/mob/living/silicon/robot/proc/update_robot_light()
	if(lights_on)
		if(intenselight)
			set_light(6, 1)
		else
			set_light(4, 0.75)
	else
		set_light(0)

// this function displays jetpack pressure in the stat panel
/mob/living/silicon/robot/proc/show_jetpack_pressure()
	// if you have a jetpack, show the internal tank pressure
	var/obj/item/tank/jetpack/current_jetpack = installed_jetpack()
	if (current_jetpack)
		stat("Internal Atmosphere Info", current_jetpack.name)
		stat("Tank Pressure", current_jetpack.air_contents.return_pressure())


// this function returns the robots jetpack, if one is installed
/mob/living/silicon/robot/proc/installed_jetpack()
	if(module)
		return (locate(/obj/item/tank/jetpack) in module.equipment)
	return 0


// this function displays the cyborgs current cell charge in the stat panel
/mob/living/silicon/robot/proc/show_cell_power()
	if(cell)
		stat(null, text("Charge Left: [round(cell.percent())]%"))
		stat(null, text("Cell Rating: [round(cell.maxcharge)]")) // Round just in case we somehow get crazy values
		stat(null, text("Power Cell Load: [round(used_power_this_tick)]W"))
	else
		stat(null, text("No Cell Inserted!"))


// update the status screen display
/mob/living/silicon/robot/Stat()
	. = ..()
	if (statpanel("Status"))
		show_cell_power()
		show_jetpack_pressure()
		stat(null, text("Lights: [lights_on ? "ON" : "OFF"]"))
		if(module)
			for(var/datum/matter_synth/ms in module.synths)
				stat("[ms.name]: [ms.energy]/[ms.max_energy_multiplied]")

/mob/living/silicon/robot/restrained()
	return 0

/mob/living/silicon/robot/bullet_act(obj/item/projectile/Proj)
	if (status_flags & GODMODE)
		return PROJECTILE_FORCE_MISS
	..(Proj)
	if(prob(75) && Proj.damage > 0) spark_system.start()
	return 2


/mob/living/silicon/robot/post_use_item(obj/item/tool, mob/user, interaction_handled, use_call, click_params)
	..()

	// Spark when hit
	if (use_call == "weapon")
		spark_system.start()

/mob/living/silicon/robot/crowbar_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(opened)
		// Close cover
		if(cell)
			user.visible_message(
				SPAN_NOTICE("[user] starts closing [src]'s maintenance hatch with [tool]."),
				SPAN_NOTICE("You start closing [src]'s maintenance hatch with [tool]."),
			)
			if(!tool.use_as_tool(src, user, 5 SECONDS, volume = 50, skill_path = SKILL_DEVICES, do_flags = DO_REPAIR_CONSTRUCT))
				return
			if(!opened)
				USE_FEEDBACK_FAILURE("[src]'s maintenance hatch is already closed.")
				return
			if(!cell)
				USE_FEEDBACK_FAILURE("[src]'s cell needs to remain in place to close \his maintenance hatch.")
				return
			opened = FALSE
			update_icon()
			user.visible_message(
				SPAN_NOTICE("[user] closes [src]'s maintenance hatch with [tool]."),
				SPAN_NOTICE("You close [src]'s maintenance hatch with [tool]."),
			)
			return

		// Remove MMI
		if(wiresexposed && wires.IsAllCut())
			if(!mmi)
				USE_FEEDBACK_FAILURE("[src] has no brain to remove.")
				return
			user.visible_message(
				SPAN_NOTICE("[user] starts removing [src]'s [mmi.name] with [tool]."),
				SPAN_NOTICE("You start removing [src]'s [mmi.name] with [tool]."),
			)
			if(!tool.use_as_tool(src, user, 5 SECONDS, volume = 50, skill_path = SKILL_DEVICES, do_flags = DO_PUBLIC_UNIQUE))
				return
			if(!mmi)
				USE_FEEDBACK_FAILURE("[src] has no longer has a brain to remove.")
				return
			user.visible_message(
				SPAN_NOTICE("[user] removes [src]'s [mmi.name] with [tool]."),
				SPAN_NOTICE("You remove [src]'s [mmi.name] with [tool]."),
			)
			dismantle(user)
			return

		// Remove component
		var/list/removable_components = list()
		for(var/key in components)
			if (key == "power cell")
				continue
			var/datum/robot_component/component = components[key]
			if (component.installed != 0)
				removable_components += key
		if(!length(removable_components))
			USE_FEEDBACK_FAILURE("[src] has no components to remove.")
			return
		var/input = input(user, "Whick component do you want to pry out?", "[name] - Remove Component") as null|anything in removable_components
		if(!input || !user.use_sanity_check(src, tool))
			return
		var/datum/robot_component/component = components[input]
		if(component.installed == 0)
			USE_FEEDBACK_FAILURE("[src] no longer has [input] to remove.")
			return
		var/obj/item/robot_parts/robot_component/removed_component = component.wrapped
		if(istype(removed_component))
			removed_component.brute = component.brute_damage
			removed_component.burn = component.electronics_damage
		removed_component.forceMove(loc)
		if(component.installed == 1)
			component.uninstall()
		component.installed = 0
		component.wrapped = null
		user.visible_message(
			SPAN_NOTICE("[user] removes [removed_component] from [src]'s [component.name] slot with [tool]."),
			SPAN_NOTICE("You remove [removed_component] from [src]'s [component.name] slot with [tool].")
		)
		return

	// Open the panel
	if(locked)
		USE_FEEDBACK_FAILURE("[src]'s maintenance hatch is locked and cannot be opened.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] starts prying open [src]'s maintenance hatch with [tool]."),
		SPAN_NOTICE("You start prying open [src]'s maintenance hatch with [tool].")
	)
	if(!tool.use_as_tool(src, user, 5 SECONDS, volume = 50, skill_path = SKILL_DEVICES, do_flags = DO_PUBLIC_UNIQUE))
		return
	if(locked)
		USE_FEEDBACK_FAILURE("[src]'s maintenance hatch is locked and cannot be opened.")
		return
	user.visible_message(
		SPAN_NOTICE("[user] pries open [src]'s maintenance hatch with [tool]."),
		SPAN_NOTICE("You pry open [src]'s maintenance hatch with [tool].")
	)
	opened = TRUE
	update_icon()
	return

/mob/living/silicon/robot/multitool_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!wiresexposed)
		USE_FEEDBACK_FAILURE("[src]'s wiring must be exposed before you can access them.")
		return
	wires.Interact(user)

/mob/living/silicon/robot/screwdriver_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!opened)
		USE_FEEDBACK_FAILURE("[src]'s maintenance panel must be opened before you can access the wiring or radio.")
		return
	var/input = input(user, "What would you like to access?", "[name] - Screwdriver Access") as null|anything in list("Wiring", "Radio")
	if(!input)
		return
	if(!opened)
		USE_FEEDBACK_FAILURE("[src]'s maintenance panel must be opened before you can access the wiring or radio.")
		return
	switch (input)
		// Passthrough to radio
		if("Radio")
			if(!silicon_radio)
				USE_FEEDBACK_FAILURE("[src] doesn't have a radio to access.")
				return
			var/result = tool.resolve_attackby(silicon_radio, user)
			if(result)
				update_icon()
		// Toggle wire panel
		if("Wiring")
			if(cell)
				USE_FEEDBACK_FAILURE("[src]'s power cell must be removed before you can access the wiring.")
				return
			if(!tool.use_as_tool(src, user, volume = 50, do_flags = DO_REPAIR_CONSTRUCT))
				return
			wiresexposed = !wiresexposed
			update_icon()
			user.visible_message(
				SPAN_NOTICE("[user] [wiresexposed ? "exposes" : "unexposes"] [src]'s wiring with [tool]."),
				SPAN_NOTICE("You [wiresexposed ? "expose" : "unexpose"] [src]'s wiring with [tool].")
			)

/mob/living/silicon/robot/wirecutter_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(!wiresexposed)
		USE_FEEDBACK_FAILURE("[src]'s wiring must be exposed before you can access them.")
		return
	wires.Interact(user)

/mob/living/silicon/robot/welder_act(mob/living/user, obj/item/tool)
	. = ITEM_INTERACT_SUCCESS
	if(user == src)
		balloon_alert(user, "вы не можете ремонтировать себя!")
		return
	if(!getBruteLoss())
		balloon_alert(user, "нет физических повреждений!")
		return
	if(!tool.tool_start_check(user, 1))
		return
	balloon_alert(user, "ремонт")
	if(!tool.use_as_tool(src, user, 1 SECONDS, 1, 50, SKILL_DEVICES, do_flags = DO_PUBLIC_UNIQUE) || !getBruteLoss())
		return
	USE_FEEDBACK_REPAIR_GENERAL
	adjustBruteLoss(-30)
	updatehealth()

/mob/living/silicon/robot/use_tool(obj/item/tool, mob/user, list/click_params)
	// Components - Attempt to install
	for (var/key in components)
		var/datum/robot_component/component = components[key]
		if (component.accepts_component(tool))
			if (!opened)
				USE_FEEDBACK_FAILURE("[src]'s maintenance hatch must be open before you can install [tool].")
				return TRUE
			if (component.installed)
				USE_FEEDBACK_FAILURE("[src] already has [component.wrapped] installed in [component] slot.")
				return TRUE
			if (!user.unEquip(tool, src))
				FEEDBACK_UNEQUIP_FAILURE(user, tool)
				return TRUE
			component.installed = TRUE
			component.wrapped = tool
			component.install()
			if (istype(tool, /obj/item/robot_parts/robot_component))
				var/obj/item/robot_parts/robot_component/component_tool = tool
				component.brute_damage = component_tool.brute
				component.electronics_damage = component_tool.burn
			user.visible_message(
				SPAN_NOTICE("[user] installs [tool] into [src]."),
				SPAN_NOTICE("You install [tool] into [src].")
			)
			return TRUE
		// Intentionally allows other interactions here, if there was no valid component

	// Cable Coil - Repair burn damage
	if (isCoil(tool))
		if (!wiresexposed)
			USE_FEEDBACK_FAILURE("[src]'s wires must be exposed to repair electronics damage.")
			return TRUE
		if (!getFireLoss())
			USE_FEEDBACK_FAILURE("[src] has no electronics damage to repair.")
			return TRUE
		var/obj/item/stack/cable_coil/cable = tool
		if (!cable.can_use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 1, "to repair [src]'s electronics damage.")
			return TRUE
		user.visible_message(
			SPAN_NOTICE("[user] starts repairing some of the electronics in [src] with [cable.get_vague_name(FALSE)]."),
			SPAN_NOTICE("You start repairing some of the electronics in [src] with [cable.get_exact_name(1)]."),
		)
		if (!do_after(user, 1 SECOND, src, DO_PUBLIC_UNIQUE) || !user.use_sanity_check(src, tool))
			return TRUE
		if (!wiresexposed)
			USE_FEEDBACK_FAILURE("[src]'s wires must be exposed to repair electronics damage.")
			return TRUE
		if (!getFireLoss())
			USE_FEEDBACK_FAILURE("[src] has no electronics damage to repair.")
			return TRUE
		if (!cable.can_use(1))
			USE_FEEDBACK_STACK_NOT_ENOUGH(cable, 1, "to repair [src]'s electronics damage.")
			return TRUE
		cable.use(1)
		adjustFireLoss(-30)
		updatehealth()
		user.visible_message(
			SPAN_NOTICE("[user] repairs some of the electronics in [src] with [cable.get_vague_name(FALSE)]."),
			SPAN_NOTICE("You repair some of the electronics in [src] with some [cable.get_exact_name(1)]."),
		)
		return TRUE

	// Encryption key - Passthrough to radio
	if (istype(tool, /obj/item/device/encryptionkey))
		if (!opened)
			USE_FEEDBACK_FAILURE("[src]'s maintenance panel must be opened before you can access the radio.")
			return TRUE
		if (tool.resolve_attackby(src, user, click_params))
			return TRUE

	// ID Card - Toggle panel lock
	var/obj/item/card/id/id = tool.GetIdCard()
	if (istype(id))
		var/id_name = GET_ID_NAME(id, tool)
		if (emagged)
			to_chat(user, SPAN_WARNING("[src]'s panel lock seems slightly damaged."))
		if (opened)
			USE_FEEDBACK_FAILURE("[src]'s cover must be closed before you can lock it.")
			return TRUE
		if (!check_access(id))
			USE_FEEDBACK_ID_CARD_DENIED(src, id_name)
			return TRUE
		locked = !locked
		update_icon()
		user.visible_message(
			SPAN_NOTICE("[user] scans [tool] over [src]'s maintenance hatch, toggling it [locked ? "locked" : "unlocked"]."),
			SPAN_NOTICE("You scan [id_name] over [src]'s maintenance hatch, toggling it [locked ? "locked" : "unlocked"]."),
			range = 1
		)
		return TRUE

	// Matter Bin - Install/swap matter bin
	if (istype(tool, /obj/item/stock_parts/matter_bin))
		if (!opened)
			USE_FEEDBACK_FAILURE("[src]'s maintenance hatch must be opened before you can install [tool].")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		if (storage)
			user.visible_message(
				SPAN_NOTICE("[user] replaces [src]'s [storage.name] with [tool]."),
				SPAN_NOTICE("You replace [src]'s [storage.name] with [tool].")
			)
			storage.dropInto(loc)
		else
			user.visible_message(
				SPAN_NOTICE("[user] installs [tool] into [src]."),
				SPAN_NOTICE("You install [tool] into [src].")
			)
		storage = tool
		handle_selfinsert(tool, user)
		recalculate_synth_capacities()
		return TRUE

	// Power Cell - Install cell
	if (istype(tool, /obj/item/cell))
		if (!opened)
			USE_FEEDBACK_FAILURE("[src]'s maintenance hatch must be opened before you can install [tool].")
			return TRUE
		if (cell)
			USE_FEEDBACK_FAILURE("[src] already has [cell] installed.")
			return TRUE
		if (wiresexposed)
			USE_FEEDBACK_FAILURE("[src]'s wiring panel must be closed before you can install [tool].")
			return TRUE
		if (tool.w_class != ITEM_SIZE_NORMAL)
			USE_FEEDBACK_FAILURE("[tool] is too [tool.w_class < ITEM_SIZE_NORMAL ? "small" : "large"] to fit in [src].")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		var/datum/robot_component/component = components["power cell"]
		cell = tool
		handle_selfinsert(cell, user)
		component.installed = 1
		component.wrapped = tool
		component.install()
		component.brute_damage = 0
		component.electronics_damage = 0
		user.visible_message(
			SPAN_NOTICE("[user] installs [tool] into [src]."),
			SPAN_NOTICE("You install [tool] into [src].")
		)
		return TRUE

	// Robot Upgrade Module - Apply upgrade
	if (istype(tool, /obj/item/borg/upgrade))
		if (!opened)
			USE_FEEDBACK_FAILURE("[src]'s maintenance hatch must be opened before you can install [tool].")
			return TRUE
		var/obj/item/borg/upgrade/upgrade = tool
		if (!module && upgrade.require_module)
			USE_FEEDBACK_FAILURE("[src] must choose a module before [tool] can be installed.")
			return TRUE
		if (upgrade.locked)
			USE_FEEDBACK_FAILURE("[tool] is locked and cannot be used.")
			return TRUE
		if (!user.unEquip(tool, src))
			FEEDBACK_UNEQUIP_FAILURE(user, tool)
			return TRUE
		if (!upgrade.action(src))
			return TRUE
		handle_selfinsert(tool, user)
		user.visible_message(
			SPAN_NOTICE("[user] installs [tool] into [src]."),
			SPAN_NOTICE("You install [tool] into [src].")
		)
		return TRUE

	return ..()


/mob/living/silicon/robot/proc/handle_selfinsert(obj/item/W, mob/user)
	if ((user == src) && istype(get_active_hand(),/obj/item/gripper))
		var/obj/item/gripper/H = get_active_hand()
		if (W.loc == H) //if this triggers something has gone very wrong, and it's safest to abort
			return
		else if (H.wrapped == W)
			H.wrapped = null
			H.update_icon()

/mob/living/silicon/robot/attack_hand(mob/user)

	add_fingerprint(user)

	if(istype(user,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		if(H.species.can_shred(H) || (MUTATION_FERAL in H.mutations))
			attack_generic(H, rand(10,20), "slashed")
			playsound(loc, 'sound/weapons/bite.ogg', 50, 1)
			if (prob(20))
				playsound(loc, 'sound/effects/sparks1.ogg', 50, 1)
			return

	if(opened && !wiresexposed && (!istype(user, /mob/living/silicon)))
		var/datum/robot_component/cell_component = components["power cell"]
		if(cell)
			cell.update_icon()
			cell.add_fingerprint(user)
			user.put_in_active_hand(cell)
			to_chat(user, "You remove [cell].")
			cell = null
			cell_component.wrapped = null
			cell_component.installed = 0
			update_icon()
		else if(cell_component.installed == -1)
			cell_component.installed = 0
			var/obj/item/broken_device = cell_component.wrapped
			to_chat(user, "You remove [broken_device].")
			user.put_in_active_hand(broken_device)

//Robots take half damage from basic attacks.
/mob/living/silicon/robot/attack_generic(mob/user, damage, attack_message)
	..(user,floor(damage/2),attack_message)

/mob/living/silicon/robot/get_req_access()
	return req_access

/mob/living/silicon/robot/on_update_icon()
	ClearOverlays()
	if(stat == CONSCIOUS)
		var/eye_icon_state = "eyes-[module_sprites[icontype]]"
		if(ICON_HAS_STATE(icon, eye_icon_state))
			if(!eye_overlays)
				eye_overlays = list()
			var/image/eye_overlay = eye_overlays[eye_icon_state]
			if(!eye_overlay)
				eye_overlay = image(icon, eye_icon_state)
				var/mutable_appearance/A = emissive_appearance(icon, eye_icon_state)
				eye_overlay.AddOverlays(A)
				eye_overlays[eye_icon_state] = eye_overlay
				z_flags |= ZMM_MANGLE_PLANES
			AddOverlays(eye_overlay)

	if(opened)
		var/panelprefix = custom_sprite ? src.ckey : "ov"
		if(wiresexposed)
			AddOverlays("[panelprefix]-openpanel +w")
		else if(cell)
			AddOverlays("[panelprefix]-openpanel +c")
		else
			AddOverlays("[panelprefix]-openpanel -c")

	if (module_active && istype(module_active,/obj/item/borg/combat/shield))
		if (modtype == "Combat")
			AddOverlays("[module_sprites[icontype]]-shield")

	if(modtype == "Combat")
		if(module_active && istype(module_active,/obj/item/borg/combat/mobility))
			icon_state = "[module_sprites[icontype]]-roll"
		else
			icon_state = module_sprites[icontype]
		return

/mob/living/silicon/robot/proc/installed_modules()

	if(!module)
		pick_module()
		return
	var/dat = "<HEAD><TITLE>Modules</TITLE></HEAD><BODY>\n"
	dat += {"
	<B>Activated Modules</B>
	<BR>
	Module 1: [module_state_1 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_1]>[module_state_1]<A>" : "No Module"]<BR>
	Module 2: [module_state_2 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_2]>[module_state_2]<A>" : "No Module"]<BR>
	Module 3: [module_state_3 ? "<A HREF=?src=\ref[src];mod=\ref[module_state_3]>[module_state_3]<A>" : "No Module"]<BR>
	<BR>
	<B>Installed Modules</B><BR><BR>"}


	for (var/obj in module.equipment)
		if (!obj)
			dat += text("<B>Resource depleted</B><BR>")
		else if (IsHolding(obj))
			dat += text("[obj]: <B>Activated</B><BR>")
		else
			dat += text("[obj]: <A HREF=?src=\ref[src];act=\ref[obj]>Activate</A><BR>")

	show_browser(src, dat, "window=robotmod")


/mob/living/silicon/robot/OnSelfTopic(href_list, topic_status)
	if (topic_status == STATUS_INTERACTIVE)
		if (href_list["showalerts"])
			open_subsystem(/datum/nano_module/alarm_monitor/all)
			return TOPIC_HANDLED

		if (href_list["mod"])
			var/obj/item/O = locate(href_list["mod"])
			if (istype(O) && (O.loc == src))
				O.attack_self(src)
			return TOPIC_HANDLED

		if (href_list["act"])
			var/obj/item/O = locate(href_list["act"])
			if (!istype(O))
				return TOPIC_HANDLED

			if(!(O in module.equipment))
				return TOPIC_HANDLED

			if (IsHolding(O))
				to_chat(src, "Already activated")
				return TOPIC_HANDLED
			if (!HasFreeHand())
				to_chat(src, "You need to disable a module first!")
				return TOPIC_HANDLED

			if(!module_state_1)
				module_state_1 = O
				O.hud_layerise()
				O.forceMove(src)
				O.equipped_robot()
				if(istype(module_state_1,/obj/item/borg/sight))
					sight_mode |= module_state_1:sight_mode
			else if(!module_state_2)
				module_state_2 = O
				O.hud_layerise()
				O.forceMove(src)
				O.equipped_robot()
				if(istype(module_state_2,/obj/item/borg/sight))
					sight_mode |= module_state_2:sight_mode
			else if(!module_state_3)
				module_state_3 = O
				O.hud_layerise()
				O.forceMove(src)
				O.equipped_robot()
				if(istype(module_state_3,/obj/item/borg/sight))
					sight_mode |= module_state_3:sight_mode
			installed_modules()
			return TOPIC_HANDLED

		if (href_list["deact"])
			var/obj/item/O = locate(href_list["deact"])
			if (IsHolding(O))
				if(module_state_1 == O)
					module_state_1 = null
				else if(module_state_2 == O)
					module_state_2 = null
				else if(module_state_3 == O)
					module_state_3 = null
				O.forceMove(null)
			else
				to_chat(src, "Module isn't activated")
			installed_modules()
			return TOPIC_HANDLED
	return ..()

/mob/living/silicon/robot/proc/radio_menu()
	if (silicon_radio)
		silicon_radio.interact(src)//Just use the radio's Topic() instead of bullshit special-snowflake code


/mob/living/silicon/robot/Move(a, b, flag)

	. = ..()

	if(module)
		if(module.type == /obj/item/robot_module/janitor)
			var/turf/tile = loc
			if(isturf(tile))
				tile.clean_blood()
				tile.remove_cleanables()
				if (istype(tile, /turf/simulated))
					var/turf/simulated/S = tile
					S.dirt = 0
				for(var/A in tile)
					if(istype(A, /obj/item))
						var/obj/item/cleaned_item = A
						cleaned_item.clean_blood()
					else if(istype(A, /mob/living/carbon/human))
						var/mob/living/carbon/human/cleaned_human = A
						if(cleaned_human.lying)
							if(cleaned_human.head)
								cleaned_human.head.clean_blood()
								cleaned_human.update_inv_head(0)
							if(cleaned_human.wear_suit)
								cleaned_human.wear_suit.clean_blood()
								cleaned_human.update_inv_wear_suit(0)
							else if(cleaned_human.w_uniform)
								cleaned_human.w_uniform.clean_blood()
								cleaned_human.update_inv_w_uniform(0)
							if(cleaned_human.shoes)
								cleaned_human.shoes.clean_blood()
								cleaned_human.update_inv_shoes(0)
							cleaned_human.clean_blood(1)
							to_chat(cleaned_human, SPAN_WARNING("[src] cleans your face!"))
		return

/mob/living/silicon/robot/proc/self_destruct()
	gib()
	return

/mob/living/silicon/robot/proc/UnlinkSelf()
	disconnect_from_ai()
	lawupdate = FALSE
	lockcharge = FALSE
	scrambledcodes = TRUE


/mob/living/silicon/robot/proc/ResetSecurityCodes()
	set category = "Silicon Commands"
	set name = "Reset Identity Codes"
	set desc = "Scrambles your security and identification codes and resets your current buffers. Unlocks you and but permanently severs you from your AI and the robotics console and will deactivate your camera system."

	var/mob/living/silicon/robot/R = src

	if(R)
		R.UnlinkSelf()
		to_chat(R, "Buffers flushed and reset. Camera system shutdown.  All systems operational.")
		src.verbs -= /mob/living/silicon/robot/proc/ResetSecurityCodes

/mob/living/silicon/robot/proc/SetLockdown(state = 1)
	// They stay locked down if their wire is cut.
	if(wires.LockedCut())
		state = 1
	else if(has_zeroth_law())
		state = 0

	if(lockcharge != state)
		lockcharge = state
		UpdateLyingBuckledAndVerbStatus()
		return 1
	return 0

/mob/living/silicon/robot/mode()
	set name = "Activate Held Object"
	set category = "IC"
	set src = usr

	var/obj/item/W = get_active_hand()
	if (W)
		W.attack_self(src)

	return

/mob/living/silicon/robot/proc/choose_icon(triesleft, list/module_sprites)
	set waitfor = 0
	if(!length(module_sprites))
		to_chat(src, "Something is badly wrong with the sprite selection. Harass a coder.")
		return

	icon_selected = 0
	src.icon_selection_tries = triesleft
	if(length(module_sprites) == 1 || !client)
		if(!(icontype in module_sprites))
			icontype = module_sprites[1]
	else
		icontype = input("Select an icon! [triesleft ? "You have [triesleft] more chance\s." : "This is your last try."]", "Robot Icon", icontype, null) in module_sprites
	icon_state = module_sprites[icontype]
	update_icon()

	if (length(module_sprites) > 1 && triesleft >= 1 && client)
		icon_selection_tries--
		var/choice = input("Look at your icon - is this what you want?") in list("Yes","No")
		if(choice=="No")
			choose_icon(icon_selection_tries, module_sprites)
			return

	icon_selected = TRUE
	icon_selection_tries = 0
	to_chat(src, "Your icon has been set. You now require a module reset to change it.")

/mob/living/silicon/robot/proc/sensor_mode() //Medical/Security HUD controller for borgs
	set name = "Set Sensor Augmentation"
	set category = "Silicon Commands"
	set desc = "Augment visual feed with internal sensor overlays."
	toggle_sensor_mode()

/mob/living/silicon/robot/proc/add_robot_verbs()
	src.verbs |= robot_verbs_default

/mob/living/silicon/robot/proc/remove_robot_verbs()
	src.verbs -= robot_verbs_default

// Uses power from cyborg's cell. Returns 1 on success or 0 on failure.
// Properly converts using CELLRATE now! Amount is in Joules.
/mob/living/silicon/robot/proc/cell_use_power(amount = 0)
	// No cell inserted
	if(!cell)
		return 0

	var/power_use = amount * CYBORG_POWER_USAGE_MULTIPLIER
	if(cell.checked_use(CELLRATE * power_use))
		used_power_this_tick += power_use
		return 1
	return 0

/mob/living/silicon/robot/binarycheck()
	if(is_component_functioning("comms"))
		var/datum/robot_component/RC = get_component("comms")
		use_power(RC.active_usage)
		return 1
	return 0

/mob/living/silicon/robot/proc/notify_ai(notifytype, first_arg, second_arg)
	if(!connected_ai)
		return
	switch(notifytype)
		if(ROBOT_NOTIFICATION_NEW_UNIT) //New Robot
			to_chat(connected_ai, "<br><br>[SPAN_NOTICE("NOTICE - New [lowertext(braintype)] connection detected: <a href='byond://?src=\ref[connected_ai];track2=\ref[connected_ai];track=\ref[src]'>[name]</a>")]<br>")
		if(ROBOT_NOTIFICATION_NEW_MODULE) //New Module
			to_chat(connected_ai, "<br><br>[SPAN_NOTICE("NOTICE - [braintype] module change detected: [name] has loaded the [first_arg].")]<br>")
		if(ROBOT_NOTIFICATION_MODULE_RESET)
			to_chat(connected_ai, "<br><br>[SPAN_NOTICE("NOTICE - [braintype] module reset detected: [name] has unloaded the [first_arg].")]<br>")
		if(ROBOT_NOTIFICATION_NEW_NAME) //New Name
			if(first_arg != second_arg)
				to_chat(connected_ai, "<br><br>[SPAN_NOTICE("NOTICE - [braintype] reclassification detected: [first_arg] is now designated as [second_arg].")]<br>")
/mob/living/silicon/robot/proc/disconnect_from_ai()
	if(connected_ai)
		sync() // One last sync attempt
		connected_ai.connected_robots -= src
		connected_ai = null

/mob/living/silicon/robot/proc/connect_to_ai(mob/living/silicon/ai/AI)
	if(AI && AI != connected_ai)
		disconnect_from_ai()
		connected_ai = AI
		connected_ai.connected_robots |= src
		notify_ai(ROBOT_NOTIFICATION_NEW_UNIT)
		sync()

/mob/living/silicon/robot/emag_act(remaining_charges, mob/user)
	if(!opened)//Cover is closed
		if(locked)
			if(prob(90))
				to_chat(user, "You emag the cover lock.")
				locked = FALSE
			else
				to_chat(user, "You fail to emag the cover lock.")
				to_chat(src, "Hack attempt detected.")
			return 1
		else
			to_chat(user, "The cover is already unlocked.")
		return

	if(opened) //Cover is open
		if(emagged)
			return //Prevents the X has hit Y with Z message also you cant emag them twice
		if(wiresexposed)
			to_chat(user, "You must close the panel first")
			return
		else
			sleep(6)
			lawupdate = FALSE
			disconnect_from_ai()
			to_chat(user, "You emag [src]'s interface.")
			log_and_message_admins("emagged cyborg [key_name_admin(src)].  Laws overridden.", src)
			clear_supplied_laws()
			clear_inherent_laws()
			laws = new /datum/ai_laws/syndicate_override
			var/time = time2text(world.realtime,"hh:mm:ss")
			GLOB.lawchanges.Add("[time] <B>:</B> [user.name]([user.key]) emagged [name]([key])")
			set_zeroth_law("Only [user.real_name] and people \he designates as being such are operatives.")
			SetLockdown(0)
			. = 1
			spawn()
				to_chat(src, SPAN_DANGER("ALERT: Foreign software detected."))
				sleep(5)
				to_chat(src, SPAN_DANGER("Initiating diagnostics..."))
				sleep(20)
				to_chat(src, SPAN_DANGER("SynBorg v1.7.1 loaded."))
				sleep(5)
				to_chat(src, SPAN_DANGER("LAW SYNCHRONISATION ERROR"))
				sleep(5)
				to_chat(src, SPAN_DANGER("Would you like to send a report to NanoTraSoft? Y/N"))
				sleep(10)
				to_chat(src, SPAN_DANGER(" N"))
				sleep(20)
				to_chat(src, SPAN_DANGER("ERRORERRORERROR"))
				to_chat(src, "<b>Obey these laws:</b>")
				laws.show_laws(src)
				to_chat(src, SPAN_DANGER("ALERT: [user.real_name] is your new master. Obey your new laws and his commands."))
				if (module && !module.is_emagged)
					module.handle_emagged(src)
				else
					emagged = TRUE
				update_icon()
			return TRUE

/mob/living/silicon/robot/incapacitated(incapacitation_flags = INCAPACITATION_DEFAULT)
	if ((incapacitation_flags & INCAPACITATION_FORCELYING) && (lockcharge || !is_component_functioning("actuator")))
		return 1
	if ((incapacitation_flags & INCAPACITATION_KNOCKOUT) && !is_component_functioning("actuator"))
		return 1
	return ..()

/mob/living/silicon/robot/proc/dismantle(mob/user)
	var/obj/item/robot_parts/robot_suit/C = new dismantle_type(loc)
	C.dismantled_from(src)
	qdel(src)

// Resting as a robot breaks things. Block it from happening.
/mob/living/silicon/robot/lay_down()
	return
