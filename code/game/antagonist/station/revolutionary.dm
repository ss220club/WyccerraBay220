GLOBAL_DATUM_INIT(revs, /datum/antagonist/revolutionary, new)

/datum/antagonist/revolutionary
	id = MODE_REVOLUTIONARY
	role_text = "Глава Революции"
	role_text_plural = "Революционеры"
	feedback_tag = "rev_objective"
	antag_indicator = "hud_rev_head"
	welcome_text = "Достучаться до справедливости можно только прикладами винтовок! Долой капиталистов! Долой буржуазию!"
	victory_text = "Руководители отделов были освобождены от своих должностей! Да Здравствует революция! Ура товарищи!"
	loss_text = "Руководителям отделов удалось остановить революцию!"
	victory_feedback_tag = "победа - главы мертва"
	loss_feedback_tag = "поражение - главы революционеров мертвы"
	flags = ANTAG_SUSPICIOUS | ANTAG_VOTABLE
	antaghud_indicator = "hud_rev"
	skill_setter = /datum/antag_skill_setter/station

	hard_cap = 2
	hard_cap_round = 4
	initial_spawn_req = 2
	initial_spawn_target = 4

	//Inround revs.
	faction_role_text = "Revolutionary"
	faction_descriptor = "Revolution"
	faction_verb = /mob/living/proc/convert_to_rev
	faction_welcome = "Помогите делу свергнуть правящий класс. Не причиняйте вреда своим собратьям-борцам за свободу."
	faction_indicator = "hud_rev"
	faction_invisible = 1
	faction = "revolutionary"

	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg)
	restricted_jobs = list(/datum/job/captain, /datum/job/hop, /datum/job/hos, /datum/job/chief_engineer, /datum/job/rd, /datum/job/cmo, /datum/job/lawyer, /datum/job/officer, /datum/job/warden, /datum/job/detective)


/datum/antagonist/revolutionary/create_global_objectives()
	if(!..())
		return
	global_objectives = list()
	for(var/mob/living/carbon/human/player in SSmobs.mob_list)
		if(!player.mind || player.stat==2 || !(player.mind.assigned_role in SSjobs.titles_by_department(COM)))
			continue
		var/datum/objective/rev/rev_obj = new
		rev_obj.target = player.mind
		rev_obj.explanation_text = "Убить, захватить или обратить [player.real_name], [player.mind.assigned_role]."
		global_objectives += rev_obj

/datum/antagonist/revolutionary/equip(mob/living/carbon/human/revolutionary_mob)
	spawn_uplink(revolutionary_mob)
	. = ..()
	if(!.)
		return

/datum/antagonist/revolutionary/proc/spawn_uplink(mob/living/carbon/human/revolutionary_mob)
	setup_uplink_source(revolutionary_mob, DEFAULT_TELECRYSTAL_AMOUNT)
