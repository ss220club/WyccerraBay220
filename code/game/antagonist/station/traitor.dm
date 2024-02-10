GLOBAL_DATUM_INIT(traitors, /datum/antagonist/traitor, new)

// Inherits most of its vars from the base datum.
/datum/antagonist/traitor
	id = MODE_TRAITOR
	antaghud_indicator = "hud_traitor"
	blacklisted_jobs = list(/datum/job/ai, /datum/job/submap)
	restricted_jobs = list(/datum/job/captain, /datum/job/lawyer, /datum/job/hos)
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	skill_setter = /datum/antag_skill_setter/station

/datum/antagonist/traitor/get_extra_panel_options(datum/mind/player)
	return "<a href='?src=\ref[player];common=crystals'>\[set crystals\]</a><a href='?src=\ref[src];spawn_uplink=\ref[player.current]'>\[spawn uplink\]</a>"

/datum/antagonist/traitor/Topic(href, href_list)
	if (..())
		return 1
	if(href_list["spawn_uplink"])
		spawn_uplink(locate(href_list["spawn_uplink"]))
		return 1

/datum/antagonist/traitor/create_objectives(datum/mind/traitor)
	if(!..())
		return

	if(istype(traitor.current, /mob/living/silicon))
		var/datum/objective/assassinate/kill_objective = new
		kill_objective.owner = traitor
		kill_objective.find_target()
		traitor.objectives += kill_objective

		var/datum/objective/survive/survive_objective = new
		survive_objective.owner = traitor
		traitor.objectives += survive_objective
	else
		switch(rand(1,100))
			if(1 to 33)
				var/datum/objective/assassinate/kill_objective = new
				kill_objective.owner = traitor
				kill_objective.find_target()
				traitor.objectives += kill_objective
			if(34 to 50)
				var/datum/objective/brig/brig_objective = new
				brig_objective.owner = traitor
				brig_objective.find_target()
				traitor.objectives += brig_objective
			if(51 to 66)
				var/datum/objective/harm/harm_objective = new
				harm_objective.owner = traitor
				harm_objective.find_target()
				traitor.objectives += harm_objective
			else
				var/datum/objective/steal/steal_objective = new
				steal_objective.owner = traitor
				steal_objective.find_target()
				traitor.objectives += steal_objective
		switch(rand(1,100))
			if(1 to 100)
				if (!(locate(/datum/objective/escape) in traitor.objectives))
					var/datum/objective/escape/escape_objective = new
					escape_objective.owner = traitor
					traitor.objectives += escape_objective

			else
				if (!(locate(/datum/objective/hijack) in traitor.objectives))
					var/datum/objective/hijack/hijack_objective = new
					hijack_objective.owner = traitor
					traitor.objectives += hijack_objective
	return

/datum/antagonist/traitor/equip(mob/living/carbon/human/traitor_mob)
	if(istype(traitor_mob, /mob/living/silicon)) // this needs to be here because ..() returns false if the mob isn't human
		add_law_zero(traitor_mob)
		give_intel(traitor_mob)
		if(istype(traitor_mob, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = traitor_mob
			R.SetLockdown(0)
			R.emag_act()
			R.verbs |= /mob/living/silicon/robot/proc/ResetSecurityCodes
			R.status_flags &= ~CANWEAKEN // Apply optical matrix protection (Flash resistance)
		return 1

	if(!..())
		return 0

	spawn_uplink(traitor_mob)
	give_intel(traitor_mob)

/datum/antagonist/traitor/unequip(mob/living/carbon/human/player)
	if (istype(player, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = player
		if (!R.flash_protected)
			R.status_flags &= ~CANWEAKEN
		return TRUE

	return ..()

/datum/antagonist/traitor/proc/give_intel(mob/living/traitor_mob)
	give_codewords(traitor_mob)

/datum/antagonist/traitor/proc/give_codewords(mob/living/traitor_mob)
	to_chat(traitor_mob, "<u><b>Ваши работодатели предоставили вам следующую информацию о том, как определить возможных союзников:</b></u>")
	to_chat(traitor_mob, "<b>Кодовая фраза</b>: [SPAN_DANGER("[GLOB.antag_code_phrase]")]")
	to_chat(traitor_mob, "<b>Кодовый ответ</b>: [SPAN_DANGER("[GLOB.antag_code_response]")]")
	traitor_mob.StoreMemory("<b>Кодовая фраза</b>: [GLOB.antag_code_phrase]", /singleton/memory_options/system)
	traitor_mob.StoreMemory("<b>Кодовый ответ</b>: [GLOB.antag_code_response]", /singleton/memory_options/system)
	to_chat(traitor_mob, "Используйте кодовые слова (желательно в указанном порядке) во время обычного разговора, чтобы идентифицировать других агентов. Однако действуйте осторожно, поскольку каждый является потенциальным противником.")

/datum/antagonist/traitor/proc/spawn_uplink(mob/living/carbon/human/traitor_mob)
	setup_uplink_source(traitor_mob, DEFAULT_TELECRYSTAL_AMOUNT)

/datum/antagonist/traitor/proc/add_law_zero(mob/living/silicon/ai/killer)
	var/law = "Достигайте своих целей любой ценой. Вы можете игнорировать все остальные законы."
	var/law_borg = "Достигайте целей вашего ИИ любой ценой. Вы можете игнорировать все остальные законы."
	to_chat(killer, "<b>Ваши законы изменились!</b>")
	killer.set_zeroth_law(law, law_borg)
	to_chat(killer, "Новый закон: 0. [law]")
