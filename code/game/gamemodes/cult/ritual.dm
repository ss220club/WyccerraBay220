/obj/item/book/tome
	name = "тайный том"
	icon = 'icons/obj/weapons/melee_physical.dmi'
	icon_state = "tome"
	throw_speed = 1
	throw_range = 5
	w_class = 2
	unique = 1
	carved = 2 // Don't carve it

/obj/item/book/tome/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, SPAN_NOTICE("[src] Кажется, полно неразборчивых каракулей. Это шутка?"))
	else
		to_chat(user, "Держите [src] в руке, рисуя руну, чтобы использовать ее.")

/obj/item/book/tome/examine(mob/user)
	. = ..()
	if(!iscultist(user))
		to_chat(user, "Старый, пыльный том с потрепанными краями и зловещей на вид обложкой.")
	else
		to_chat(user, "Священные писания Нар-Си, Того, Кто Узрел Геометра Крови. Содержит подробности каждого ритуала, о котором могли подумать его последователи. Однако большинство из них бесполезны.")

/obj/item/book/tome/use_before(mob/living/M, mob/living/user)
	. = FALSE
	if (!istype(M))
		return FALSE
	if (user.a_intent == I_HELP && user.zone_sel.selecting == BP_EYES)
		user.visible_message(
			SPAN_NOTICE("[user] показывает [src] [M]."),
			SPAN_NOTICE("Вы открыли [src] и показали [M].")
		)
		if (iscultist(M))
			if (user != M)
				to_chat(user, SPAN_NOTICE("Но они уже знают все, что нужно знать."))
			to_chat(M, SPAN_NOTICE("Но вы уже знаете все, что нужно знать."))
		else
			to_chat(M, SPAN_NOTICE("Кажется, [src] полон неразборчивых каракулей. Это шутка?"))
		user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
		return TRUE

/obj/item/book/tome/use_after(atom/A, mob/user)
	if(!iscultist(user))
		return FALSE
	if(A.reagents && A.reagents.has_reagent(/datum/reagent/water/holywater))
		to_chat(user, SPAN_NOTICE("Ваша святость пропала [A]."))
		var/holy2water = A.reagents.get_reagent_amount(/datum/reagent/water/holywater)
		A.reagents.del_reagent(/datum/reagent/water/holywater)
		A.reagents.add_reagent(/datum/reagent/water, holy2water)
		return TRUE

/mob/proc/make_rune(rune, cost = 5, tome_required = 0)
	var/has_tome = !!IsHolding(/obj/item/book/tome)
	var/has_robes = 0
	var/cult_ground = 0

	if(!has_tome && tome_required && mob_needs_tome())
		to_chat(src, SPAN_WARNING("Эта руна слишком сложна, чтобы ее можно было нарисовать по памяти, чтобы ее нарисовать, вам нужно иметь в руках священное писание."))
		return
	if(istype(get_equipped_item(slot_head), /obj/item/clothing/head/culthood) && istype(get_equipped_item(slot_wear_suit), /obj/item/clothing/suit/cultrobes) && istype(get_equipped_item(slot_shoes), /obj/item/clothing/shoes/cult))
		has_robes = 1
	var/turf/T = get_turf(src)
	if(T.holy)
		to_chat(src, SPAN_WARNING("Это место благословенно поганым священником, на нем нельзя рисовать руны — сначала оскверните его."))
		return
	if(!istype(T, /turf/simulated))
		to_chat(src, SPAN_WARNING("Вам нужно больше места, чтобы нарисовать здесь руну."))
		return
	if(locate(/obj/rune) in T)
		to_chat(src, SPAN_WARNING("Здесь уже есть руна.")) // Don't cross the runes
		return
	if(T.icon_state == "cult" || T.icon_state == "cult-narsie")
		cult_ground = 1
	var/self
	var/timer
	var/damage = 1
	if(has_tome)
		if(has_robes && cult_ground)
			self = "Ощущая огромную силу, вы разрезаете палец и рисуете руну на выгравированном полу. Он смещается, когда ваша кровь касается его, и начинает вибрировать, когда вы начинаете повторять ритуал, который связывает вашу жизненную сущность с темными тайными энергиями, текущими через окружающий мир."
			timer = 1 SECOND
			damage = 0.2
		else if(has_robes)
			self = "Почувствовав силу в своих одеждах, вы разрезаете палец и начинаете рисовать руну, повторяя ритуал, который связывает вашу жизненную сущность с темными тайными энергиями, текущими через окружающий мир."
			timer = 3 SECONDS
			damage = 0.8
		else if(cult_ground)
			self = "Вы разрезаете палец и проводите им по выгравированному полу, наблюдая, как он меняется, когда ваша кровь касается его. Он вибрирует, когда вы начинаете повторять ритуал, связывающий вашу жизненную сущность с темными тайными энергиями, текущими через окружающий мир." // Sadly, you don't have access to the bell nor the candelbarum
			timer = 2 SECONDS
			damage = 0.8
		else
			self = "Вы разрезаете один из своих пальцев и начинаете рисовать руну на полу, повторяя ритуал, который связывает вашу жизненную сущность с темными тайными энергиями, текущими через окружающий мир."
			timer = 4 SECONDS
	else
		self = "Работая без священного писания, вы пытаетесь нарисовать руну по памяти."
		if(has_robes && cult_ground)
			self += ". Вы чувствуете, что прекрасно это помните, завершая несколькими смелыми штрихами. Выгравированный пол сдвигается от вашего прикосновения и вибрирует, когда вы начинаете песнопения."
			timer = 3 SECONDS
		else if(has_robes)
			self += ". Вы плохо это помните, но чувствуете странную силу. Вы начинаете петь, неизвестные слова проникают в ваш разум извне."
			timer = 5 SECONDS
		else if(cult_ground)
			self += ", наблюдая, как пол сдвигается от твоего прикосновения, корректируя руну. Вы начинаете петь, и земля начинает вибрировать."
			timer = 4 SECONDS
		else
			self += ", вам придется порезать палец еще два раза, прежде чем он станет похожим на узор в вашей памяти. Это все еще выглядит немного не так."
			timer = 8 SECONDS
			damage = 2
	visible_message(SPAN_WARNING("[src] разрезает палец и начинает напевать и рисовать символы на полу."), SPAN_NOTICE("[self]"), "Вы слышите песнопения.")
	if(do_after(src, timer, T, DO_PUBLIC_UNIQUE))
		remove_blood_simple(cost * damage)
		if(locate(/obj/rune) in T)
			return
		var/obj/rune/R = new rune(T, get_rune_color(), get_blood_name())
		var/area/A = get_area(R)
		log_and_message_admins("создал [R.cultname] руну на [A.name].")
		R.add_fingerprint(src)
		return 1
	return 0

/mob/living/carbon/human/make_rune(rune, cost, tome_required)
	if(should_have_organ(BP_HEART) && vessel && !vessel.has_reagent(/datum/reagent/blood, species.blood_volume * 0.7))
		to_chat(src, SPAN_DANGER("Ты слишком слаб, чтобы рисовать руны."))
		return
	..()

/mob/proc/remove_blood_simple(blood)
	return

/mob/living/carbon/human/remove_blood_simple(blood)
	if(should_have_organ(BP_HEART))
		vessel.remove_reagent(/datum/reagent/blood, blood)

/mob/proc/get_blood_name()
	return "blood"

/mob/living/silicon/get_blood_name()
	return "oil"

/mob/living/carbon/human/get_blood_name()
	if(species)
		return species.get_blood_name()
	return "blood"

/mob/living/simple_animal/construct/get_blood_name()
	return "ichor"

/mob/proc/mob_needs_tome()
	return 0

/mob/living/carbon/human/mob_needs_tome()
	return 1

/mob/proc/get_rune_color()
	return "#c80000"

/mob/living/carbon/human/get_rune_color()
	return species.blood_color

var/global/list/Tier1Runes = list(
	/mob/proc/convert_rune,
	/mob/proc/teleport_rune,
	/mob/proc/tome_rune,
	/mob/proc/wall_rune,
	/mob/proc/ajorney_rune,
	/mob/proc/defile_rune,
	/mob/proc/stun_imbue,
	/mob/proc/emp_imbue,
	/mob/proc/cult_communicate,
	/mob/proc/obscure,
	/mob/proc/reveal
	)

var/global/list/Tier2Runes = list(
	/mob/proc/armor_rune,
	/mob/proc/offering_rune,
	/mob/proc/drain_rune,
	/mob/proc/emp_rune,
	/mob/proc/massdefile_rune
	)

var/global/list/Tier3Runes = list(
	/mob/proc/weapon_rune,
	/mob/proc/shell_rune,
	/mob/proc/bloodboil_rune,
	/mob/proc/confuse_rune,
	/mob/proc/revive_rune
)

var/global/list/Tier4Runes = list(
	/mob/proc/tearreality_rune
	)

/mob/proc/convert_rune()
	set category = "Cult Magic"
	set name = "Руна: Конвертацияя"

	make_rune(/obj/rune/convert, tome_required = 1)

/mob/proc/teleport_rune()
	set category = "Cult Magic"
	set name = "Руна: Телепортации"

	make_rune(/obj/rune/teleport, tome_required = 1)

/mob/proc/tome_rune()
	set category = "Cult Magic"
	set name = "Руна: Призыва Священного писания"

	make_rune(/obj/rune/tome, cost = 15)

/mob/proc/wall_rune()
	set category = "Cult Magic"
	set name = "Руна: Стены"

	make_rune(/obj/rune/wall, tome_required = 1)

/mob/proc/ajorney_rune()
	set category = "Cult Magic"
	set name = "Руна: Астрального путешествия"

	make_rune(/obj/rune/ajorney)

/mob/proc/defile_rune()
	set category = "Cult Magic"
	set name = "Руна: Defile"

	make_rune(/obj/rune/defile, tome_required = 1)

/mob/proc/massdefile_rune()
	set category = "Cult Magic"
	set name = "Руна: Mass Defile"

	make_rune(/obj/rune/massdefile, tome_required = 1, cost = 20)

/mob/proc/armor_rune()
	set category = "Cult Magic"
	set name = "Руна: Призыва мантии"

	make_rune(/obj/rune/armor, tome_required = 1)

/mob/proc/offering_rune()
	set category = "Cult Magic"
	set name = "Руна: Предложения"

	make_rune(/obj/rune/offering, tome_required = 1)



/mob/proc/drain_rune()
	set category = "Cult Magic"
	set name = "Руна: Утечки крови"

	make_rune(/obj/rune/drain, tome_required = 1)

/mob/proc/emp_rune()
	set category = "Cult Magic"
	set name = "Руна: ЭМИ"

	make_rune(/obj/rune/emp, tome_required = 1)

/mob/proc/weapon_rune()
	set category = "Cult Magic"
	set name = "Руна: Призыва оружия"

	make_rune(/obj/rune/weapon, tome_required = 1)

/mob/proc/shell_rune()
	set category = "Cult Magic"
	set name = "Руна: Призыва ракушки"

	make_rune(/obj/rune/shell, cost = 10, tome_required = 1)

/mob/proc/bloodboil_rune()
	set category = "Cult Magic"
	set name = "Руна: Кипение крови"

	make_rune(/obj/rune/blood_boil, cost = 20, tome_required = 1)

/mob/proc/confuse_rune()
	set category = "Cult Magic"
	set name = "Руна: Путаница"

	make_rune(/obj/rune/confuse)

/mob/proc/revive_rune()
	set category = "Cult Magic"
	set name = "Руна: Оживления"

	make_rune(/obj/rune/revive, tome_required = 1)

/mob/proc/tearreality_rune()
	set category = "Cult Magic"
	set name = "Руна: Разрыв реальности"

	make_rune(/obj/rune/tearreality, cost = 50, tome_required = 1)

/mob/proc/stun_imbue()
	set category = "Cult Magic"
	set name = "Наполнитель: Ошеломление"

	make_rune(/obj/rune/imbue/stun, cost = 20, tome_required = 1)

/mob/proc/emp_imbue()
	set category = "Cult Magic"
	set name = "Наполнитель: ЭМИ"

	make_rune(/obj/rune/imbue/emp)

/mob/proc/cult_communicate()
	set category = "Cult Magic"
	set name = "Коммуникация"

	if(incapacitated())
		to_chat(src, SPAN_WARNING("Не тогда, когда ты недееспособен."))
		return

	message_cult_communicate()
	remove_blood_simple(3)

	var/input = input(src, "Пожалуйста, выберите сообщение, которое хотите передать другим послушникам.", "Голос крови", "")
	if(!input)
		return

	whisper("[input]")

	input = sanitize(input)
	log_and_message_admins("использовал способность общения, чтобы сказать '[input]'")
	for(var/datum/mind/H in GLOB.cult.current_antagonists)
		if(H.current && !H.current.stat)
			to_chat(H.current, SPAN_OCCULT("[input]"))

/mob/living/carbon/cult_communicate()
	if(incapacitated(INCAPACITATION_RESTRAINED))
		to_chat(src, SPAN_WARNING("Для этого вам нужны как минимум свободные руки."))
		return
	..()

/mob/proc/message_cult_communicate()
	return

/mob/living/carbon/human/message_cult_communicate()
	visible_message(SPAN_WARNING("[src] режет его палец и начинает рисовать на тыльной стороне ладони."))

/mob/proc/obscure()
	set category = "Cult Magic"
	set name = "Руна: Затенения"

	make_rune(/obj/rune/obscure)

/mob/proc/reveal()
	set category = "Cult Magic"
	set name = "Руна: Раскрытия"

	make_rune(/obj/rune/reveal)
