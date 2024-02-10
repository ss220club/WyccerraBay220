/mob/observer/ghost/var/ghost_magic_cd = 0

/datum/antagonist/cultist/proc/add_ghost_magic(mob/observer/ghost/M)
	if(max_cult_rating >= CULT_GHOSTS_1)
		M.verbs += /mob/observer/ghost/proc/flick_lights
		M.verbs += /mob/observer/ghost/proc/bloody_doodle
		M.verbs += /mob/observer/ghost/proc/shatter_glass
		M.verbs += /mob/observer/ghost/proc/slice
		if(max_cult_rating >= CULT_GHOSTS_2)
			M.verbs += /mob/observer/ghost/proc/move_item
			M.verbs += /mob/observer/ghost/proc/whisper_to_cultist
			M.verbs += /mob/observer/ghost/proc/bite_someone
			M.verbs += /mob/observer/ghost/proc/chill_someone
			if(max_cult_rating >= CULT_GHOSTS_3)
				M.verbs += /mob/observer/ghost/proc/whisper_to_anyone
				M.verbs += /mob/observer/ghost/proc/bloodless_doodle
				M.verbs += /mob/observer/ghost/proc/toggle_visiblity

/mob/observer/ghost/proc/ghost_ability_check()
	var/turf/T = get_turf(src)
	if(T.holy)
		to_chat(src, SPAN_NOTICE("Вы не можете использовать свои способности на благословенной земле."))
		return 0
	if(ghost_magic_cd > world.time)
		to_chat(src, SPAN_NOTICE("Вам нужно подождать [round((ghost_magic_cd - world.time) / 10)] секунд, прежде чем вы сможете использовать свои способности."))
		return 0
	return 1

/mob/observer/ghost/proc/flick_lights()
	set category = "Cult"
	set name = "Мерцание света"
	set desc = "Создать мерцание света вокруг себя"

	if(!ghost_ability_check())
		return

	for(var/obj/machinery/light/L in range(3))
		L.flicker()

	ghost_magic_cd = world.time + 30 SECONDS

/mob/observer/ghost/proc/bloody_doodle()
	set category = "Cult"
	set name = "Написать кровью"
	set desc = "Напишите короткое сообщение кровью на полу или стене. Помните: никакого IC в ООС или ООС в IC."

	bloody_doodle_proc(0)

/mob/observer/ghost/proc/bloody_doodle_proc(bloodless = 0)
	if(!ghost_ability_check())
		return

	var/doodle_color = COLOR_BLOOD_HUMAN

	var/turf/simulated/T = get_turf(src)
	if(!istype(T))
		to_chat(src, SPAN_WARNING("Тут нельзя рисовать."))
		return

	var/num_doodles = 0
	for(var/obj/decal/cleanable/blood/writing/W in T)
		num_doodles++
	if(num_doodles > 4)
		to_chat(src, SPAN_WARNING("Нет места для надписи!"))
		return

	var/obj/decal/cleanable/blood/choice
	if(!bloodless)
		var/list/choices = list()
		for(var/obj/decal/cleanable/blood/B in range(1))
			if(B.amount > 0)
				choices += B

		if(!length(choices))
			to_chat(src, SPAN_WARNING("Рядом нет крови, которую можно было бы использовать."))
			return

		choice = input(src, "Какую кровь вы бы хотели использовать?") as null|anything in choices
		if(!choice)
			return

		if(choice.basecolor)
			doodle_color = choice.basecolor

	var/max_length = 50

	var/message = sanitize(input("Напиши сообщение. Оно не может быть длиннее [max_length].", "Надпись кровью", ""))

	if(!ghost_ability_check())
		return

	if(message && (bloodless || (choice && (choice in range(1)))))
		if(length(message) > max_length)
			message += "-"
			to_chat(src, SPAN_WARNING("У тебя кончилась кровь, чтобы писать!"))

		var/obj/decal/cleanable/blood/writing/W = new(T)
		W.basecolor = doodle_color
		W.update_icon()
		W.message = message
		W.add_hiddenprint(src)
		if(!bloodless)
			W.visible_message(SPAN_WARNING("Невидимые пальцы грубо рисуют что-то кровью. [T]."))
		else
			W.visible_message(SPAN_WARNING("Кровь появляется из ниоткуда, когда невидимые пальцы грубо что-то рисуют. [T]."))

		log_admin("[src] ([src.key]) использовал призрачную магию, чтобы писать '[message]' - [x]-[y]-[z]")

	ghost_magic_cd = world.time + 30 SECONDS

/mob/observer/ghost/proc/shatter_glass()
	set category = "Cult"
	set name = "Шум: скрежет стекла"
	set desc = "Издайте звук скрежета стекла."

	if(!ghost_ability_check())
		return

	playsound(loc, "shatter", 50, 1)

	ghost_magic_cd = world.time + 5 SECONDS

/mob/observer/ghost/proc/slice()
	set category = "Cult"
	set name = "Шум: рез"
	set desc = "Издайте звук удара меча."

	if(!ghost_ability_check())
		return

	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1)

	ghost_magic_cd = world.time + 5 SECONDS

/mob/observer/ghost/proc/move_item()
	set category = "Cult"
	set name = "Двигать предметы"
	set desc = "Переместите небольшой предмет туда, где вы находитесь."

	if(!ghost_ability_check())
		return

	var/turf/T = get_turf(src)

	var/list/obj/item/choices = list()
	for(var/obj/item/I in range(1))
		if(I.w_class <= 2)
			choices += I

	if(!length(choices))
		to_chat(src, SPAN_WARNING("Подходящих предметов поблизости нет."))
		return

	var/obj/item/choice = input(src, "Какой предмет вы хотели бы вытащить?") as null|anything in choices
	if(!choice || !(choice in range(1)) || choice.w_class > 2)
		return

	if(!ghost_ability_check())
		return

	if(step_to(choice, T))
		choice.visible_message(SPAN_WARNING("[choice] внезапно двигается!"))

	ghost_magic_cd = world.time + 60 SECONDS

/mob/observer/ghost/proc/whisper_to_cultist()
	set category = "Cult"
	set name = "Шепот культисту"
	set desc = "Пошепните человеку по вашему выбору. Однако они не поймут вас, если только они не культисты."

	whisper_proc()

/mob/observer/ghost/proc/whisper_proc(anyone = 0)
	if(!ghost_ability_check())
		return

	var/list/mob/living/choices = list()
	for(var/mob/living/M in range(1))
		choices += M

	var/mob/living/choice = input(src, "Кому ты хочешь шепнуть?") as null|anything in choices
	if(!choice)
		return

	var/message = sanitize(input("Решите, что вы хотите шептать.", "Шепот", ""))

	if(!ghost_ability_check())
		return

	if(message)
		if(iscultist(choice) || anyone)
			to_chat(choice, SPAN_NOTICE("Вы слышите слабый шепот... Он говорит... \"[message]\""))
			log_and_message_admins("использовал магию призраков, чтобы сказать '[message]' [choice] и был услышан - [x]-[y]-[z]")
		else
			to_chat(choice, SPAN_NOTICE("Вы слышите слабый шепот, но не можете разобрать слов."))
			log_and_message_admins("использовал магию призраков, чтобы сказать '[message]' [choice] но не был услышан - [x]-[y]-[z]")
		to_chat(src, "Ты шепчешь [choice]. Возможно он услышал тебя.")

	ghost_magic_cd = world.time + 100 SECONDS

/mob/observer/ghost/proc/bite_someone()
	set category = "Cult"
	set name = "Укус"
	set desc = "Укусить или поцарапать кого-либо."

	if(!ghost_ability_check())
		return

	var/list/mob/living/carbon/human/choices = list()
	for(var/mob/living/carbon/human/H in range(1))
		choices += H

	var/mob/living/carbon/human/choice = input(src, "Кого ты хочешь поцарапать?") as null|anything in choices
	if(!choice)
		return

	if(!ghost_ability_check())
		return

	var/method = pick("укусить", "поцарапать")
	to_chat(choice, SPAN_DANGER("Что-то невидимое [method] тебя!"))
	choice.apply_effect(5, EFFECT_PAIN, 0)
	to_chat(src, SPAN_NOTICE("Ты [method] [choice]."))

	log_and_message_admins("использовал призрачную магию, чтобы укусить [choice] - [x]-[y]-[z]")

	ghost_magic_cd = world.time + 60 SECONDS

/mob/observer/ghost/proc/chill_someone()
	set category = "Cult"
	set name = "Холод"
	set desc = "Пройти сквозь кого-то, заставив его на мгновение почувствовать холод загробной жизни."

	if(!ghost_ability_check())
		return

	var/list/mob/living/carbon/human/choices = list()
	for(var/mob/living/carbon/human/H in range(1))
		choices += H

	var/mob/living/carbon/human/choice = input(src, "Кого ты хочешь напугать?") as null|anything in choices
	if(!choice)
		return

	if(!ghost_ability_check())
		return

	to_chat(choice, SPAN_DANGER("Вы чувствуете, как будто сквозь вас прошло что-то холодное!"))
	if(choice.bodytemperature >= choice.species.cold_level_1 + 1)
		choice.bodytemperature = max(choice.species.cold_level_1 + 1, choice.bodytemperature - 30)
	to_chat(src, SPAN_NOTICE("Вы проходите через [choice], давая им внезапный холод."))

	log_and_message_admins("спользовал магию призраков, чтобы охладить [choice] - [x]-[y]-[z]")

	ghost_magic_cd = world.time + 60 SECONDS

/mob/observer/ghost/proc/whisper_to_anyone()
	set category = "Cult"
	set name = "Шепот на ум"
	set desc = "Пошепните человеку по вашему выбору."

	whisper_proc(1)

/mob/observer/ghost/proc/bloodless_doodle()
	set category = "Cult"
	set name = "Напиши собственной кровью"
	set desc = "Напишите короткое сообщение кровью на полу или стене. Чтобы использовать это, вам не нужна кровь поблизости."

	bloody_doodle_proc(1)

/mob/observer/ghost/proc/toggle_visiblity()
	set category = "Cult"
	set name = "Переключить видимость"
	set desc = "Позволяет становиться видимым или невидимым по желанию."

	if(invisibility && !ghost_ability_check())
		return

	if(invisibility == 0)
		ghost_magic_cd = world.time + 60 SECONDS
		to_chat(src, SPAN_INFO("Теперь вы невидимы."))
		visible_message(SPAN_CLASS("emote", "Оно исчезает из поля зрения ..."))
		set_invisibility(INVISIBILITY_OBSERVER)
		mouse_opacity = 1
	else
		ghost_magic_cd = world.time + 60 SECONDS
		to_chat(src, SPAN_INFO("Вы невидимый."))
		set_invisibility(0)
		mouse_opacity = 0 // This is so they don't make people invincible to melee attacks by hovering over them
