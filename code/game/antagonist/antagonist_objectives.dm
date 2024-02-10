/datum/antagonist/proc/create_global_objectives(override=0)
	if(config.objectives_disabled != CONFIG_OBJECTIVE_ALL && !override)
		return 0
	if(global_objectives && length(global_objectives))
		return 0
	return 1

/datum/antagonist/proc/create_objectives(datum/mind/player, override=0)
	if(config.objectives_disabled != CONFIG_OBJECTIVE_ALL && !override)
		return 0
	if(create_global_objectives(override) || length(global_objectives))
		player.objectives |= global_objectives
	return 1

/datum/antagonist/proc/get_special_objective_text()
	return ""

/mob/proc/add_objectives()
	set name = "Получить цели"
	set desc = "Получите дополнительные цели."
	set category = "OOC"

	src.verbs -= /mob/proc/add_objectives

	if(!src.mind)
		return

	var/all_antag_types = GLOB.all_antag_types_
	for(var/tag in all_antag_types) //we do all of them in case an admin adds an antagonist via the PP. Those do not show up in gamemode.
		var/datum/antagonist/antagonist = all_antag_types[tag]
		if(antagonist && antagonist.is_antagonist(src.mind))
			antagonist.create_objectives(src.mind,1)

	to_chat(src, "<b>[FONT_LARGE("Эти цели являются полностью добровольными. Вы не обязаны их заполнять.")]</b>")
	show_objectives(src.mind)

/mob/living/proc/set_ambition()
	set name = "Выбрать амбиции"
	set category = "IC"
	set src = usr

	if(!mind)
		return
	if(!is_special_character(mind))
		to_chat(src, SPAN_WARNING("Возможно, у вас есть цели, но эта панель предназначена только для \
		антагонистов.  Пожалуйста сделайте репорт о наденном баге!"))
		return

	var/datum/goal/ambition/goal = SSgoals.ambitions[mind]
	var/new_goal = sanitize(input(src, "Напишите короткое предложение о том, чего надеется достичь ваш персонаж. \
	сегодня как антагонист.  Помните, что это совершенно необязательно.  Оно будет показано в конце \
	раунда для всех.", "Цель антагониста", (goal ? html_decode(goal.description) : "")) as null|message)
	if(!isnull(new_goal))
		if(!goal)
			goal = new /datum/goal/ambition(mind)
		goal.description = new_goal
		to_chat(src, SPAN_NOTICE("Вы поставили перед собой цель <b>'[goal.description]'</b>. Вы можете проверить свои цели с помощью <b>Показать цели</b>."))
	else
		to_chat(src, SPAN_NOTICE("Вы оставляете свои амбиции позади."))
		if(goal)
			qdel(goal)
	log_and_message_admins("поставил перед собой следующие цели: [new_goal].")

//some antagonist datums are not actually antagonists, so we might want to avoid
//sending them the antagonist meet'n'greet messages.
//E.G. ERT
/datum/antagonist/proc/show_objectives_at_creation(datum/mind/player)
	if(src.show_objectives_on_creation)
		show_objectives(player)
