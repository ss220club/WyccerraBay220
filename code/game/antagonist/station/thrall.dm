GLOBAL_DATUM_INIT(thralls, /datum/antagonist/thrall, new)

/datum/antagonist/thrall
	role_text = "Тралл"
	role_text_plural = "Траллы"
	welcome_text = "Ваш разум больше не принадлежит только вам..."
	id = MODE_THRALL
	flags = ANTAG_IMPLANT_IMMUNE

	var/list/thrall_controllers = list()

/datum/antagonist/thrall/create_objectives(datum/mind/player)
	var/mob/living/controller = thrall_controllers["\ref[player]"]
	if(!controller)
		return // Someone is playing with buttons they shouldn't be.
	var/datum/objective/obey = new
	obey.owner = player
	obey.explanation_text = "Подчиняйся своему мастеру, [controller.real_name], во всем."
	player.objectives |= obey

/datum/antagonist/thrall/add_antagonist(datum/mind/player, ignore_role, do_not_equip, move_to_spawn, do_not_announce, preserve_appearance, mob/new_controller)
	if(!new_controller)
		return 0
	. = ..()
	if(.) thrall_controllers["\ref[player]"] = new_controller

/datum/antagonist/thrall/greet(datum/mind/player)
	. = ..()
	var/mob/living/controller = thrall_controllers["\ref[player]"]
	if(controller)
		to_chat(player, SPAN_DANGER("Ваша воля была подчинена [controller.real_name]. Подчиняйтесь ему во всем."))
