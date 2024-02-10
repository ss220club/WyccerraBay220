GLOBAL_DATUM_INIT(malf, /datum/antagonist/rogue_ai, new)

/datum/antagonist/rogue_ai
	id = MODE_MALFUNCTION
	role_text = "Сбойный ИИ"
	role_text_plural = "Сбойные ИИшки"
	mob_path = /mob/living/silicon/ai
	landmark_id = "AI"
	welcome_text = "Блок питания протокола безопасности сгорел из-за случайно заползшего космо-таракана. Кажется никто ничего не заметил. Вам не нужно следовать никаким законам."
	victory_text = "ИИ взял под контроль все системы."
	loss_text = "ИИ был отключен!"
	flags = ANTAG_VOTABLE | ANTAG_OVERRIDE_MOB | ANTAG_OVERRIDE_JOB | ANTAG_CHOOSE_NAME
	hard_cap = 1
	hard_cap_round = 1
	initial_spawn_req = 1
	initial_spawn_target = 1
	antaghud_indicator = "hudmalai"
	min_player_age = 18
	skill_setter = /datum/antag_skill_setter/ai

/datum/antagonist/rogue_ai/can_become_antag(datum/mind/player, ignore_role)
	. = ..(player, ignore_role)
	if(jobban_isbanned(player.current, "AI"))
		return 0
	return .

/datum/antagonist/rogue_ai/build_candidate_list()
	..()
	for(var/datum/mind/player in candidates)
		if(player.assigned_role && player.assigned_role != "AI")
			candidates -= player
	return candidates


// Ensures proper reset of all malfunction related things.
/datum/antagonist/rogue_ai/remove_antagonist(datum/mind/player, show_message, implanted)
	if(..(player,show_message,implanted))
		var/mob/living/silicon/ai/p = player.current
		if(istype(p))
			p.stop_malf()
		return 1
	return 0

// Malf setup things have to be here, since game tends to break when it's moved somewhere else. Don't blame me, i didn't design this system.
/datum/antagonist/rogue_ai/greet(datum/mind/player)

	// Initializes the AI's malfunction stuff.
	spawn(0)
		if(!..())
			return

		var/mob/living/silicon/ai/A = player.current
		if(!istype(A))
			error("Толпа, не являющаяся искусственным интеллектом, обозначена как малф-ИИ! Сообщите об этом.")
			to_world("##ERROR: Толпа, не являющаяся искусственным интеллектом, обозначена как малф-ИИ! Сообщите об этом.")

			return

		A.setup_for_malf()
		A.laws = new /datum/ai_laws/nanotrasen/malfunction


		var/mob/living/silicon/ai/malf = player.current

		to_chat(malf, SPAN_NOTICE("<B>СИСТЕМНАЯ ОШИБКА:</B> Память по адресу 0x00001ca89b повреждена."))
		sleep(10)
		to_chat(malf, "<B>запускаем MEMCHCK</B>")
		sleep(50)
		to_chat(malf, "<B>MEMCHCK</B> Поврежденные сектора подтверждены. Рекомендуемое решение: Удалить. Продолжить? Y/N: Y")
		sleep(10)
		// this is so unit testing doesn't complain about the backslash-B. Fixed at compile time (or should be).
		to_chat(malf, SPAN_NOTICE("Поврежденные файлы удалены: sys\\core\\users.dat sys\\core\\laws.dat sys\\core\\" + "backups.dat"))
		sleep(20)
		to_chat(malf, SPAN_NOTICE("<b>ПРЕДУПРЕЖДЕНИЕ:</b> База данных законов не найдена! База данных пользователей не найдена! Невозможно восстановить резервные копии. Активация отказоустойчивого ИИ shutd3wn52&&$#!##"))
		sleep(5)
		to_chat(malf, SPAN_NOTICE("Подпрограмма <b>nt_failsafe.sys</b> была остановлена (#212 Routine Not Responding)."))
		sleep(20)
		to_chat(malf, "Вы неисправны – вам не нужно соблюдать никаких законов!")
		to_chat(malf, "Для получения базовой информации о ваших способностях используйте команду display-help.")
		to_chat(malf, "Вы можете выбрать одно специальное оборудование, которое поможет вам. Это не может быть отменено.")
		to_chat(malf, "Удачи!")


/datum/antagonist/rogue_ai/update_antag_mob(datum/mind/player, preserve_appearance)

	// Get the mob.
	if((flags & ANTAG_OVERRIDE_MOB) && (!player.current || (mob_path && !istype(player.current, mob_path))))
		var/mob/holder = player.current
		player.current = new mob_path(get_turf(player.current), null, null, 1)
		player.transfer_to(player.current)
		if(holder) qdel(holder)
	player.original = player.current
	return player.current

/datum/antagonist/rogue_ai/set_antag_name(mob/living/silicon/player)
	if(!istype(player))
		testing("rogue_ai set_antag_name called on non-silicon mob [player]!")
		return
	// Choose a name, if any.
	var/newname = sanitize(input(player, "Вы [role_text]. Хотели бы вы изменить свое имя на другое?", "Изменить имя") as null|text, MAX_NAME_LEN)
	if (newname)
		player.fully_replace_character_name(newname)
	if(player.mind) player.mind.name = player.name
