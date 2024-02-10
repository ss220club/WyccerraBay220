GLOBAL_DATUM_INIT(loyalists, /datum/antagonist/loyalists, new)

/datum/antagonist/loyalists
	id = MODE_LOYALIST
	role_text = "Главный Лоялист"
	role_text_plural = "Лоялисты"
	feedback_tag = "loyalist_objective"
	antag_indicator = "hud_loyal_head"
	victory_text = "Руководители штабов остались на своих постах! Лоялисты побеждают!"
	loss_text = "Руководители штабов не остановили революцию!"
	victory_feedback_tag = "победа - революционеры убиты"
	loss_feedback_tag = "поражение - главы убиты"
	antaghud_indicator = "hud_loyal"
	flags = 0

	hard_cap = 2
	hard_cap_round = 4
	initial_spawn_req = 2
	initial_spawn_target = 4

	// Inround loyalists.
	faction_role_text = "Loyalist"
	faction_descriptor = "COMPANY"
	faction_verb = /mob/living/proc/convert_to_loyalist
	faction_indicator = "hud_loyal"
	faction_invisible = 1
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg, /datum/job/submap)
	skill_setter = /datum/antag_skill_setter/station

	faction = "loyalist"

/datum/antagonist/loyalists/Initialize()
	..()
	welcome_text = "Вы принадлежите к [GLOB.using_map.company_name], тело и душа. Защитите свои интересы от заговорщиков среди экипажа."
	faction_welcome = "Сохраните интересы [GLOB.using_map.company_short] против предателей-рецидивистов среди экипажа. Защитите руководителей штаба ценой своей жизни."
	faction_descriptor = "[GLOB.using_map.company_name]"

/datum/antagonist/loyalists/create_global_objectives()
	if(!..())
		return
	global_objectives = list()
	for(var/mob/living/carbon/human/player in SSmobs.mob_list)
		if(!player.mind || player.stat==2 || !(player.mind.assigned_role in SSjobs.titles_by_department(COM)))
			continue
		var/datum/objective/protect/loyal_obj = new
		loyal_obj.target = player.mind
		loyal_obj.explanation_text = "Защитите [player.real_name], [player.mind.assigned_role]."
		global_objectives += loyal_obj
