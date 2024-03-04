/obj/item/psychic_power/tinker
	name = "psychokinetic crowbar"
	icon_state = "tinker"
	force = 1
	var/emulating = "Crowbar"
	tool_behaviour = TOOL_CROWBAR

/obj/item/psychic_power/tinker/attack_self()
	if(!owner || loc != owner)
		return
	var/choice = input("Select a tool to emulate.","Power") as null|anything in list(TOOL_CROWBAR, TOOL_WRENCH, TOOL_SCREWDRIVER, TOOL_WIRECUTTER, "Dismiss")
	if(!choice)
		return
	if(!owner || loc != owner)
		return
	if(choice == "Dismiss")
		sound_to(owner, 'sound/effects/psi/power_fail.ogg')
		owner.drop_from_inventory(src)
		return
	emulating = choice
	name = "psychokinetic [lowertext(emulating)]"
	to_chat(owner, SPAN_NOTICE("You begin emulating \a [lowertext(emulating)]."))
	sound_to(owner, 'sound/effects/psi/power_fabrication.ogg')
	change_tool_behaviour(emulating)
