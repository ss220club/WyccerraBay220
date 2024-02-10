GLOBAL_DATUM_INIT(ert, /datum/antagonist/ert, new)

/datum/antagonist/ert
	id = MODE_ERT
	role_text = "Аварийный авто-ответчик"
	role_text_plural = "Аварийный авто-ответчик"
	antag_text = "Вы <b>анти</b>-антагонист! В рамках правил постарайтесь спасти корабль и его команду от продолжающегося кризиса. \
				 Постарайтесь убедиться, чтобы другие игроки <i>веселились</i>, если вы растеряны, пишите в AdminHelp. \
				 Вы также должны связаться с персоналом, прежде чем предпринять какие -либо экстремальные действия. \
				 <b>Помните, что все правила за пределами тех, у кого явные исключения применимы к ГЭР!</b>"
	welcome_text = "You shouldn't see this"
	leader_welcome_text = "You shouldn't see this"
	landmark_id = "Response Team"
	id_type = /obj/item/card/id/centcom/ERT

	flags = ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_SET_APPEARANCE | ANTAG_HAS_LEADER | ANTAG_CHOOSE_NAME | ANTAG_RANDOM_EXCEPTED
	antaghud_indicator = "hudloyalist"

	hard_cap = 5
	hard_cap_round = 7
	initial_spawn_req = 5
	initial_spawn_target = 7
	show_objectives_on_creation = 0 //we are not antagonists, we do not need the antagonist shpiel/objectives

	faction = "emergency"
	no_prior_faction = TRUE

	base_to_load = /datum/map_template/ruin/antag_spawn/ert

	var/reason = ""

/datum/antagonist/ert/create_default(mob/source)
	var/mob/living/carbon/human/M = ..()
	if(istype(M)) M.age = rand(25,45)

/datum/antagonist/ert/Initialize()
	..()
	leader_welcome_text = SPAN_BOLD("Вы лидер Группы Экстренного Реагирования (ГЭР).") + "Как лидер, вы подчиняетесь командованию [GLOB.using_map.company_name]. У вас есть разрешение переопределить командира, где необходимо достичь ваших целей. Тем не менее, рекомендуется работать в команде для достижения ваших целей, если это возможно."
	welcome_text =        SPAN_BOLD("Вы сотрудник Группы Экстренного Реагирования (ГЭР).") + "Как сотрудник Группы Экстренного Реагирования (ГЭР), вы подчиняетесь вашему людеру и командованию [GLOB.using_map.company_name]."

/datum/antagonist/ert/greet(datum/mind/player)
	if(!..())
		return
	to_chat(player.current, "Вы являетесь частью Пятого Флота Быстрых Сил и Реакции (ПФБСР). Существует КРИТИЧЕСКАЯ ситуация \the [GLOB.using_map.station_name] и вам поручено решить проблему.")
	to_chat(player.current, "Вы должны сначала подготовиться и обсудить план со своей командой. Можно присоединиться к большему количеству участников, поэтому не выходите, пока не подготовились. Вскоре вы можете получить дальнейшие инструкции от начальника лично или по голосвязи.")

	if(reason)
		to_chat(player.current, SPAN_BOLD(FONT_LARGE("Вас вызвали в \the [GLOB.using_map.station_name] по следующей причине: " + SPAN_NOTICE(reason))))

//Equip proc has been moved to the map specific folders.
