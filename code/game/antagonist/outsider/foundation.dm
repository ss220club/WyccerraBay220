GLOBAL_DATUM_INIT(foundation_agents, /datum/antagonist/foundation, new)

/datum/antagonist/foundation
	id = MODE_FOUNDATION
	role_text = "Агент Фонда"
	antag_indicator = "hudfoundation"
	role_text_plural = "Фондовые Агенты"
	welcome_text = "<span class='info'>Вы полевой агент Фонда Кухулайна, \
	орган, который специализируется на устранении психических угроз. У вас есть пропуск куда угодно \
	как вам нравится, пистолет, заряженный антипси-зарядными патронами с нулевым стеклом, и четкая обязанность. Естественно, \
	никто не воспринимает ваших работодателей всерьез - до сегодня.</span>"
	antag_text = "Вы <b>анти</b>-антагонист! В рамках правил, \
		постарайтесь спасти установку и ее обитателей от продолжающегося кризиса. \
		Постарайтесь, чтобы другие игроки <i>развлеклись</i>! Если вы запутались или растерялись, всегда обращайтесь за помощью к администратору, \
		и прежде чем предпринимать крайние действия, попробуйте обратиться к администрации! \
		Продумывайте свои действия и сделайте ролевую игру захватывающей! <b>Пожалуйста, помните все \
		К агентам Фонда применяются правила, за исключением тех, которые не содержат явных исключений.</b>"

	flags = ANTAG_OVERRIDE_JOB | ANTAG_OVERRIDE_MOB | ANTAG_CLEAR_EQUIPMENT | ANTAG_CHOOSE_NAME | ANTAG_SET_APPEARANCE
	antaghud_indicator = "hudfoundation"
	landmark_id = "Response Team"
	hard_cap = 3
	hard_cap_round = 3
	initial_spawn_req = 1
	initial_spawn_target = 2
	min_player_age = 14
	faction = "foundation"
	id_type = /obj/item/card/id/foundation

/datum/antagonist/foundation/equip(mob/living/carbon/human/player)

	if(!..())
		return 0

	player.set_psi_rank(PSI_REDACTION,     3, defer_update = TRUE)
	player.set_psi_rank(PSI_COERCION,      3, defer_update = TRUE)
	player.set_psi_rank(PSI_PSYCHOKINESIS, 3, defer_update = TRUE)
	player.set_psi_rank(PSI_ENERGISTICS,   3, defer_update = TRUE)
	player.psi.update(TRUE)

	var/singleton/hierarchy/outfit/foundation = outfit_by_type(/singleton/hierarchy/outfit/foundation)
	foundation.equip(player)

	create_id("Foundation Agent", player)
