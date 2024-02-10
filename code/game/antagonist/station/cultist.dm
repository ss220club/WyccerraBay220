#define CULTINESS_PER_CULTIST 40
#define CULTINESS_PER_SACRIFICE 40
#define CULTINESS_PER_TURF 1

#define CULT_RUNES_1 200
#define CULT_RUNES_2 400
#define CULT_RUNES_3 1000

#define CULT_GHOSTS_1 400
#define CULT_GHOSTS_2 800
#define CULT_GHOSTS_3 1200

#define CULT_MAX_CULTINESS 1200 // When this value is reached, the game stops checking for updates so we don't recheck every time a tile is converted in endgame

GLOBAL_DATUM_INIT(cult, /datum/antagonist/cultist, new)

/proc/iscultist(mob/player)
	if(!GLOB.cult || !player.mind)
		return 0
	if(player.mind in GLOB.cult.current_antagonists)
		return 1

/datum/antagonist/cultist
	id = MODE_CULTIST
	role_text = "Культист"
	role_text_plural = "Культисты"
	restricted_jobs = list(/datum/job/lawyer, /datum/job/captain, /datum/job/hos, /datum/job/officer, /datum/job/warden, /datum/job/detective)
	blacklisted_jobs = list(/datum/job/ai, /datum/job/cyborg, /datum/job/chaplain, /datum/job/psychiatrist, /datum/job/submap)
	feedback_tag = "cult_objective"
	antag_indicator = "hudcultist"
	welcome_text = "У вас есть священное писание; которое поможет вам начать культ. Используйте его правильно и помните — вокруг есть и другие."
	victory_text = "Культ побеждает! Он преуспел в служении своим темным хозяевам!"
	loss_text = "Экипажу удалось остановить культ!"
	victory_feedback_tag = "победа - культ победил"
	loss_feedback_tag = "поражение - экипаж справился с культом"
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	hard_cap = 5
	hard_cap_round = 6
	initial_spawn_req = 4
	initial_spawn_target = 6
	antaghud_indicator = "hudcultist"
	skill_setter = /datum/antag_skill_setter/station

	var/allow_narsie = 1
	var/powerless = 0
	var/datum/mind/sacrifice_target
	var/list/obj/rune/teleport/teleport_runes = list()
	var/list/rune_strokes = list()
	var/list/sacrificed = list()
	var/cult_rating = 0
	var/list/cult_rating_bounds = list(CULT_RUNES_1, CULT_RUNES_2, CULT_RUNES_3, CULT_GHOSTS_1, CULT_GHOSTS_2, CULT_GHOSTS_3)
	var/max_cult_rating = 0
	var/conversion_blurb = "Вы мельком видите Царство Нар-Си, Геометра Крови. Теперь вы видите, насколько хрупок мир, вы видите, что он должен быть открыт для познания Того, Что Ждет. Помогите своим новым соотечественникам в их темных делах. Их цели — ваши, а ваши — их. Служение Темному Лорду превыше всего. Возроди его."
	var/station_summon_only = TRUE
	var/no_shuttle_summon = TRUE

	faction = "cult"

/datum/antagonist/cultist/create_global_objectives()

	if(!..())
		return

	global_objectives = list()
	if(prob(50))
		global_objectives |= new /datum/objective/cult/survive
	else
		global_objectives |= new /datum/objective/cult/eldergod

	var/datum/objective/cult/sacrifice/sacrifice = new()
	sacrifice.find_target()
	sacrifice_target = sacrifice.target
	global_objectives |= sacrifice

/datum/antagonist/cultist/equip(mob/living/carbon/human/player)

	if(!..())
		return 0

	var/obj/item/book/tome/T = new(get_turf(player))
	var/list/slots = list (
		"backpack" = slot_in_backpack,
		"left pocket" = slot_l_store,
		"right pocket" = slot_r_store,
		"left hand" = slot_l_hand,
		"right hand" = slot_r_hand,
	)
	for(var/slot in slots)
		player.equip_to_slot(T, slot)
		if(T.loc == player)
			break
	var/obj/item/storage/S = locate() in player.contents
	if(istype(S))
		T.forceMove(S)

/datum/antagonist/cultist/remove_antagonist(datum/mind/player, show_message, implanted)
	if(!..())
		return 0
	to_chat(player.current, SPAN_DANGER("Незнакомый белый свет вспыхивает в вашем разуме, очищая порчу Темного лорда и воспоминания о том времени, когда вы были его слугой."))
	player.ClearMemories(type)
	if(show_message)
		player.current.visible_message(SPAN_NOTICE("[player.current] похоже, они только что вернулись к своей старой вере!"))
	remove_cult_magic(player.current)
	remove_cultiness(CULTINESS_PER_CULTIST)

/datum/antagonist/cultist/add_antagonist(datum/mind/player, ignore_role, do_not_equip, move_to_spawn, do_not_announce, preserve_appearance)
	. = ..()
	if(.)
		to_chat(player, SPAN_OCCULT("[conversion_blurb]"))
		if(player.current && !istype(player.current, /mob/living/simple_animal/construct))
			player.current.add_language(LANGUAGE_CULT)

/datum/antagonist/cultist/remove_antagonist(datum/mind/player, show_message, implanted)
	. = ..()
	if(. && player.current && !istype(player.current, /mob/living/simple_animal/construct))
		player.current.remove_language(LANGUAGE_CULT)

/datum/antagonist/cultist/update_antag_mob(datum/mind/player)
	. = ..()
	add_cultiness(CULTINESS_PER_CULTIST)
	add_cult_magic(player.current)

/datum/antagonist/cultist/proc/add_cultiness(amount)
	cult_rating += amount
	var/old_rating = max_cult_rating
	max_cult_rating = max(max_cult_rating, cult_rating)
	if(old_rating >= CULT_MAX_CULTINESS)
		return
	var/list/to_update = list()
	for(var/i in cult_rating_bounds)
		if((old_rating < i) && (max_cult_rating >= i))
			to_update += i

	if(length(to_update))
		update_cult_magic(to_update)

/datum/antagonist/cultist/proc/update_cult_magic(list/to_update)
	if(CULT_RUNES_1 in to_update)
		for(var/datum/mind/H in GLOB.cult.current_antagonists)
			if(H.current)
				to_chat(H.current, SPAN_OCCULT("Завеса между этим миром и потусторонним становится тоньше, а ваша сила растет."))
				add_cult_magic(H.current)
	if(CULT_RUNES_2 in to_update)
		for(var/datum/mind/H in GLOB.cult.current_antagonists)
			if(H.current)
				to_chat(H.current, SPAN_OCCULT("Вы чувствуете, что ткань реальности рвется."))
				add_cult_magic(H.current)
	if(CULT_RUNES_3 in to_update)
		for(var/datum/mind/H in GLOB.cult.current_antagonists)
			if(H.current)
				to_chat(H.current, SPAN_OCCULT("Миру конец. Завеса тонка, как никогда."))
				add_cult_magic(H.current)

	if((CULT_GHOSTS_1 in to_update) || (CULT_GHOSTS_2 in to_update) || (CULT_GHOSTS_3 in to_update))
		for(var/mob/observer/ghost/D in SSmobs.mob_list)
			add_ghost_magic(D)

/datum/antagonist/cultist/proc/offer_uncult(mob/M)
	if(!iscultist(M) || !M.mind)
		return

	to_chat(M, SPAN_OCCULT("Хотите покинуть культ Нар'Си? <a href='?src=\ref[src];confirmleave=1'>ПРИНЯТЬ</a>"))

/datum/antagonist/cultist/Topic(href, href_list)
	if(href_list["confirmleave"])
		GLOB.cult.remove_antagonist(usr.mind, 1)

/datum/antagonist/cultist/proc/remove_cultiness(amount)
	cult_rating = max(0, cult_rating - amount)

/datum/antagonist/cultist/proc/add_cult_magic(mob/M)
	M.verbs += Tier1Runes

	if(max_cult_rating >= CULT_RUNES_1)
		M.verbs += Tier2Runes

		if(max_cult_rating >= CULT_RUNES_2)
			M.verbs += Tier3Runes

			if(max_cult_rating >= CULT_RUNES_3)
				M.verbs += Tier4Runes

/datum/antagonist/cultist/proc/remove_cult_magic(mob/M)
	M.verbs -= Tier1Runes
	M.verbs -= Tier2Runes
	M.verbs -= Tier3Runes
	M.verbs -= Tier4Runes
