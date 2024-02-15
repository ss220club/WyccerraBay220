/* Cards
 * Contains:
 *		DATA CARD
 *		ID CARD
 *		FINGERPRINT CARD HOLDER
 *		FINGERPRINT CARD
 */



/*
 * DATA CARDS - Used for the IC data card reader
 */
/obj/item/card
	name = "карта"
	desc = "Делает карточные дела"
	icon = 'icons/obj/tools/card.dmi'
	w_class = ITEM_SIZE_TINY
	slot_flags = SLOT_EARS

/obj/item/card/union
	name = "карта сообщества"
	desc = "Карта, показывающая членство в местном союзе работников."
	icon_state = "union"
	slot_flags = SLOT_ID
	var/signed_by

/obj/item/card/union/examine(mob/user)
	. = ..()
	if(signed_by)
		to_chat(user, "Оно было подписано [signed_by].")
	else
		to_chat(user, "У этого есть пустое место для подписи.")

/obj/item/card/union/attackby(obj/item/thing, mob/user)
	if(istype(thing, /obj/item/pen))
		if(signed_by)
			to_chat(user, SPAN_WARNING("\The [src] уже был подписан."))
		else
			var/signature = sanitizeSafe(input("Как вы хотите подписать карту?", "Карта Сообщества") as text, MAX_NAME_LEN)
			if(signature && !signed_by && !user.incapacitated() && Adjacent(user))
				signed_by = signature
				user.visible_message(SPAN_NOTICE("\The [user] signs \the [src] with a flourish."))
		return
	..()

/obj/item/card/operant_card
	name = "Оперантная регистрационная карта"
	icon_state = "warrantcard_civ"
	desc = "Регистрационная карта в деле искусственной кожи. Это отмечает названное лицо как зарегистрированного, законопослушного псионика."
	w_class = ITEM_SIZE_SMALL
	attack_verb = list("whipped")
	hitsound = 'sound/weapons/towelwhip.ogg'
	var/info
	var/potential
	var/use_rating


/obj/item/card/operant_card/proc/set_info(mob/living/carbon/human/human)
	if(!istype(human))
		return
	switch(human.psi?.rating)
		if(0)
			use_rating = "[human.psi.rating]-Лямбда"
		if(1)
			use_rating = "[human.psi.rating]-Эпсилон"
		if(2)
			use_rating = "[human.psi.rating]-Гамма"
		if(3)
			use_rating = "[human.psi.rating]-Дельта"
		if(4)
			use_rating = "[human.psi.rating]-Бета"
		if(5)
			use_rating = "[human.psi.rating]-Альфа"
		if (6 to INFINITY)
			use_rating = "[human.psi.rating]-Омега"
		else
			use_rating = "Не псионик"

	potential = "Этот человек имеет общий рейтинг ПСИ на уровне[use_rating]."
	info = {"\
		Имя: [human.real_name]\n\
		Вид: [human.get_species()]\n\
		Отпечаток: [human.dna?.uni_identity ? md5(human.dna.uni_identity) : "N/A"]\n\
		Оцененный потенциал: [potential]\
	"}


/obj/item/card/operant_card/attack_self(mob/living/user)
	user.visible_message(
		SPAN_ITALIC("\The [user] осматривает \a [src]."),
		SPAN_ITALIC("Вы осмотрели \the [src]."),
		3
	)
	to_chat(user, info || SPAN_WARNING("\The [src] является полностью пустым!"))

/obj/item/card/data
	name = "дата-карта"
	desc = "Пластиковая карточка в магнитную полоску для простого и быстрого хранения и передачи данных. У этой карточки посередине проходит полоска."
	icon_state = "data_1"
	var/detail_color = COLOR_ASSEMBLY_ORANGE
	var/function = "storage"
	var/data = "null"
	var/special = null
	var/list/files = list(  )

/obj/item/card/data/Initialize()
	.=..()
	update_icon()

/obj/item/card/data/on_update_icon()
	ClearOverlays()
	var/image/detail_overlay = image('icons/obj/tools/card.dmi', src,"[icon_state]-color")
	detail_overlay.color = detail_color
	AddOverlays(detail_overlay)

/obj/item/card/data/attackby(obj/item/I, mob/living/user)
	if(istype(I, /obj/item/device/integrated_electronics/detailer))
		var/obj/item/device/integrated_electronics/detailer/D = I
		detail_color = D.detail_color
		update_icon()
	return ..()

/obj/item/card/data/full_color
	desc = "Пластиковая карточка в магнитную полоску для простого и быстрого хранения и передачи данных. На этой карточке вся карта окрашена."
	icon_state = "data_2"

/obj/item/card/data/disk
	desc = "Пластиковая карта в магнитную полоску для простого и быстрого хранения и передачи данных. Эта карта необъяснимо похожа на дискету."
	icon_state = "data_3"

/*
 * ID CARDS
 */

/obj/item/card/emag_broken
	desc = "Это пустая идентификационная карточка с магнитной полосой и прикрепленной к ней какой-то странной схемой."
	name = "идентификационная карта"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = list(TECH_MAGNET = 2, TECH_ESOTERIC = 2)

/obj/item/card/emag_broken/examine(mob/user, distance)
	. = ..()
	if(distance <= 0 && (user.skill_check(SKILL_DEVICES, SKILL_TRAINED) || player_is_antag(user.mind)))
		to_chat(user, SPAN_WARNING("Вы можете сказать, что компоненты полностью прожарились; какая бы польза от них ни была раньше, она исчезла."))

/obj/item/card/emag_broken/get_antag_info()
	. = ..()
	. += "Вы можете использовать этот криптографический секвенсор для взлома электроники или принудительного открытия дверей, к которым у вас нет доступа. Эти действия необратимы, а количество списаний с карты ограничено!"

/obj/item/card/emag
	desc = "Это пустая идентификационная карточка с магнитной полосой и прикрепленной к ней какой-то странной схемой."
	name = "идентификационная карта"
	icon_state = "emag"
	item_state = "card-id"
	origin_tech = list(TECH_MAGNET = 2, TECH_ESOTERIC = 2)
	var/uses = 10

var/global/const/NO_EMAG_ACT = -50

/obj/item/card/emag/resolve_attackby(atom/A, mob/user)
	var/used_uses = A.emag_act(uses, user, src)
	if(used_uses == NO_EMAG_ACT)
		return ..(A, user)

	uses -= used_uses
	A.add_fingerprint(user)
	if(used_uses)
		log_and_message_admins("емагнуто \ [A].")

	if(uses<1)
		user.visible_message(SPAN_WARNING("\The [src] шипит и искрит - кажется он использовался слишком часто, функционал более не работает."))
		var/obj/item/card/emag_broken/junk = new(user.loc)
		junk.add_fingerprint(user)
		qdel(src)

	return 1

/obj/item/card/emag/Initialize()
	. = ..()
	set_extension(src, /datum/extension/chameleon/emag)

/obj/item/card/emag/get_antag_info()
	. = ..()
	. += "Вы можете использовать этот криптографический секвенсор, чтобы взломать электронику или насильно открыть двери, к которым у вас нет доступа."

/obj/item/card/id
	name = "идентификационная карта"
	desc = "Карта, используемая для обеспечения идентификатора и определения доступа."
	icon_state = "base"
	item_state = "card-id"
	slot_flags = SLOT_ID

	var/list/access = list()
	var/registered_name = "Unknown" // The name registered_name on the card
	var/associated_account_number = 0
	var/list/associated_email_login = list("login" = "", "password" = "")

	var/age = "\[UNSET\]"
	var/blood_type = "\[UNSET\]"
	var/dna_hash = "\[UNSET\]"
	var/fingerprint_hash = "\[UNSET\]"
	var/sex = "\[UNSET\]"
	var/icon/front
	var/icon/side

	//alt titles are handled a bit weirdly in order to unobtrusively integrate into existing ID system
	var/assignment = null	//can be alt title or the actual job
	var/rank = null			//actual job
	var/dorm = 0			// determines if this ID has claimed a dorm already

	var/job_access_type     // Job type to acquire access rights from, if any

	var/datum/mil_branch/military_branch = null //Vars for tracking branches and ranks on multi-crewtype maps
	var/datum/mil_rank/military_rank = null

	var/formal_name_prefix
	var/formal_name_suffix

	var/detail_color
	var/extra_details

/obj/item/card/id/Initialize()
	.=..()
	if(job_access_type)
		var/datum/job/j = SSjobs.get_by_path(job_access_type)
		if(j)
			rank = j.title
			assignment = rank
			access |= j.get_access()
			if(!detail_color)
				detail_color = j.selection_color
	update_icon()

/obj/item/card/id/get_mob_overlay(mob/user_mob, slot)
	var/image/ret = ..()
	var/overlay = overlay_image(ret.icon, "[ret.icon_state]_colors", detail_color, RESET_COLOR)
	ret.AddOverlays(overlay)
	return ret

/obj/item/card/id/on_update_icon()
	ClearOverlays()
	AddOverlays(overlay_image(icon, "[icon_state]_colors", detail_color, RESET_COLOR))
	for(var/detail in extra_details)
		AddOverlays(overlay_image(icon, detail, flags=RESET_COLOR))

/obj/item/card/id/CanUseTopic(user)
	if(user in view(get_turf(src)))
		return STATUS_INTERACTIVE

/obj/item/card/id/OnTopic(mob/user, list/href_list)
	if(href_list["look_at_id"])
		if(istype(user))
			examinate(user, src)
			return TOPIC_HANDLED

/obj/item/card/id/examine(mob/user, distance)
	. = ..()
	to_chat(user, "Говорит '[get_display_name()]'.")
	if(distance <= 1)
		show(user)

/obj/item/card/id/proc/prevent_tracking()
	return 0

/obj/item/card/id/proc/show(mob/user as mob)
	if(front && side)
		send_rsc(user, front, "front.png")
		send_rsc(user, side, "side.png")
	var/datum/browser/popup = new(user, "idcard", name, 600, 250)
	popup.set_content(dat())
	popup.open()
	return

/obj/item/card/id/proc/get_display_name()
	. = registered_name
	if(military_rank && military_rank.name_short)
		. ="[military_rank.name_short] [.][formal_name_suffix]"
	else if(formal_name_prefix || formal_name_suffix)
		. = "[formal_name_prefix][.][formal_name_suffix]"
	if(assignment)
		. += ", [assignment]"

/obj/item/card/id/proc/set_id_photo(mob/M)
	M.ImmediateOverlayUpdate()
	front = getFlatIcon(M, SOUTH, always_use_defdir = TRUE)
	side = getFlatIcon(M, WEST, always_use_defdir = TRUE)

/mob/proc/set_id_info(obj/item/card/id/id_card)
	id_card.age = 0

	id_card.formal_name_prefix = initial(id_card.formal_name_prefix)
	id_card.formal_name_suffix = initial(id_card.formal_name_suffix)
	if(client && client.prefs)
		for(var/culturetag in client.prefs.cultural_info)
			var/singleton/cultural_info/culture = SSculture.get_culture(client.prefs.cultural_info[culturetag])
			if(culture)
				id_card.formal_name_prefix = "[culture.get_formal_name_prefix()][id_card.formal_name_prefix]"
				id_card.formal_name_suffix = "[id_card.formal_name_suffix][culture.get_formal_name_suffix()]"

	id_card.registered_name = real_name

	var/pronouns = "Unset"
	var/datum/pronouns/P = choose_from_pronouns()
	if(P)
		pronouns = P.formal_term
	id_card.sex = pronouns
	id_card.set_id_photo(src)

	if(dna)
		id_card.blood_type		= dna.b_type
		id_card.dna_hash		= dna.unique_enzymes
		id_card.fingerprint_hash= md5(dna.uni_identity)

/mob/living/carbon/human/set_id_info(obj/item/card/id/id_card)
	..()
	id_card.age = age
	if(GLOB.using_map.flags & MAP_HAS_BRANCH)
		id_card.military_branch = char_branch
	if(GLOB.using_map.flags & MAP_HAS_RANK)
		id_card.military_rank = char_rank
		if (char_rank)
			var/singleton/rank_category/category = char_rank.rank_category()
			if(category)
				for(var/add_access in category.add_accesses)
					id_card.access.Add(add_access)

/obj/item/card/id/proc/dat()
	var/list/dat = list("<table><tr><td>")
	dat += text("Имя: []</A><BR>", "[formal_name_prefix][registered_name][formal_name_suffix]")
	dat += text("Местоимения: []</A><BR>\n", sex)
	dat += text("Возраст: []</A><BR>\n", age)

	if(GLOB.using_map.flags & MAP_HAS_BRANCH)
		dat += text("Branch: []</A><BR>\n", military_branch ? military_branch.name : "\[UNSET\]")
	if(GLOB.using_map.flags & MAP_HAS_RANK)
		dat += text("Ранг: []</A><BR>\n", military_rank ? military_rank.name : "\[UNSET\]")

	dat += text("Назначение: []</A><BR>\n", assignment)
	dat += text("Отпечаток: []</A><BR>\n", fingerprint_hash)
	dat += text("Группа крови: []<BR>\n", blood_type)
	dat += text("Хэш ДНК: []<BR><BR>\n", dna_hash)
	if(front && side)
		dat +="<td align = center valign = top>Фото:<br><img src=front.png height=80 width=80 border=4><img src=side.png height=80 width=80 border=4></td>"
	dat += "</tr></table>"
	return jointext(dat,null)

/obj/item/card/id/attack_self(mob/user as mob)
	user.visible_message("\The [user] показывает вам: [icon2html(src, viewers(get_turf(src)))] [src.name]. Должность: [src.assignment]",\
		"Вы показываете свое удостоверение личности: [icon2html(src, viewers(get_turf(src)))] [src.name]. Должность: [src.assignment]")

	src.add_fingerprint(user)
	return

/obj/item/card/id/GetAccess()
	return access

/obj/item/card/id/GetIdCard()
	return src

/obj/item/card/id/verb/read()
	set name = "Прочитать ID карту"
	set category = "Object"
	set src in usr

	to_chat(usr, text("[icon2html(src, usr)] []: Текущая должность на карте: [].", src.name, src.assignment))
	to_chat(usr, "Текущая группа крови на карте: [blood_type].")
	to_chat(usr, "Текущий Хэш ДНК на карте: [dna_hash].")
	to_chat(usr, "Текущие отпечатки на карте: [fingerprint_hash].")
	return

/singleton/vv_set_handler/id_card_military_branch
	handled_type = /obj/item/card/id
	handled_vars = list("military_branch")

/singleton/vv_set_handler/id_card_military_branch/handle_set_var(obj/item/card/id/id, variable, var_value, client)
	if(!var_value)
		id.military_branch = null
		id.military_rank = null
		return

	if(istype(var_value, /datum/mil_branch))
		if(var_value != id.military_branch)
			id.military_branch = var_value
			id.military_rank = null
		return

	if(ispath(var_value, /datum/mil_branch) || istext(var_value))
		var/datum/mil_branch/new_branch = GLOB.mil_branches.get_branch(var_value)
		if(new_branch)
			if(new_branch != id.military_branch)
				id.military_branch = new_branch
				id.military_rank = null
			return

	to_chat(client, SPAN_WARNING("Входные данные, должны быть существующей категории - [var_value] некорректные"))

/singleton/vv_set_handler/id_card_military_rank
	handled_type = /obj/item/card/id
	handled_vars = list("military_rank")

/singleton/vv_set_handler/id_card_military_rank/handle_set_var(obj/item/card/id/id, variable, var_value, client)
	if(!var_value)
		id.military_rank = null
		return

	if(!id.military_branch)
		to_chat(client, SPAN_WARNING("military_branch не выставленно - Недоступно"))
		return

	if(ispath(var_value, /datum/mil_rank))
		var/datum/mil_rank/rank = var_value
		var_value = initial(rank.name)

	if(istype(var_value, /datum/mil_rank))
		var/datum/mil_rank/rank = var_value
		var_value = rank.name

	if(istext(var_value))
		var/new_rank = GLOB.mil_branches.get_rank(id.military_branch.name, var_value)
		if(new_rank)
			id.military_rank = new_rank
			return

	to_chat(client, SPAN_WARNING("Ввод должен быть существующим званием, принадлежащим military_branch - [var_value] является недействительным"))

/obj/item/card/id/silver
	name = "идентификационная карта"
	desc = "Серебряная карточка, свидетельствующая о чести и преданности делу."
	item_state = "silver_id"
	job_access_type = /datum/job/hop

/obj/item/card/id/gold
	name = "идентификационная карта"
	desc = "Золотая карта, которая показывает власть и могущество."
	job_access_type = /datum/job/captain
	color = "#d4c780"
	extra_details = list("goldstripe")

/obj/item/card/id/syndicate_command
	name = "ID карта Синдиката"
	desc = "Удостоверение личности прямо из недр Синдикатаe."
	registered_name = "Syndicate"
	assignment = "Повелитель Синдиката"
	access = list(access_syndicate, access_external_airlocks)
	color = COLOR_RED_GRAY
	detail_color = COLOR_GRAY40

/obj/item/card/id/captains_spare
	name = "капитанский запасной ID"
	desc = "Запасное удостоверение личности Темнейшего."
	item_state = "gold_id"
	registered_name = "Captain"
	assignment = "Капитан"
	detail_color = COLOR_AMBER

/obj/item/card/id/captains_spare/New()
	access = get_all_station_access()
	..()

/obj/item/card/id/synthetic
	name = "\improper Синтетический идентификатор"
	desc = "Модуль доступа для легальных синтетиков."
	icon_state = "robot_base"
	assignment = "Synthetic"
	detail_color = COLOR_AMBER

/obj/item/card/id/synthetic/New()
	access = GLOB.using_map.synth_access.Copy()
	..()

/obj/item/card/id/centcom
	name = "\improper Цент-Ком ID"
	desc = "ID прямо из Цент-Кома"
	registered_name = "Центральное Командование"
	assignment = "General"
	color = COLOR_GRAY40
	detail_color = COLOR_COMMAND_BLUE
	extra_details = list("goldstripe")

/obj/item/card/id/centcom/New()
	access = get_all_centcom_access()
	..()

/obj/item/card/id/centcom/station/New()
	..()
	access |= get_all_station_access()

/obj/item/card/id/centcom/ERT
	name = "\improper Идентификатор Группы Экстренного Реагирования (ГЭР)"
	assignment = "Группы Экстренного Реагирования"

/obj/item/card/id/centcom/ERT/New()
	..()
	access |= get_all_station_access()

/obj/item/card/id/foundation_civilian
	name = "действующая регистрационная карточка"
	desc = "Регистрационная карточка в футляре из искусственной кожи. Она помечает названного человека как зарегистрированного, законопослушного псионика."
	icon_state = "warrantcard_civ"

/obj/item/card/id/foundation_civilian/on_update_icon()
	return

/obj/item/card/id/foundation
	name = "\improper Ордерная карточка фонда"
	desc = "Служебное удостоверение в красивом кожаном футляре."
	assignment = "Field Agent"
	icon_state = "warrantcard"

/obj/item/card/id/foundation/examine(mob/user, distance)
	. = ..()
	if(distance <= 1 && isliving(user))
		var/mob/living/M = user
		if(M.psi)
			to_chat(user, SPAN_WARNING("Существует псионическое принуждение, окружающее \the [src], заставляя любого, кто читает это, воспринимать это как законный документ власти. Фактический текст просто гласит: 'Я могу делать то, что хочу.'"))
		else
			to_chat(user, SPAN_NOTICE("Это реальная сделка, скрепленная печатью [GLOB.using_map.boss_name]. Это дает владельцу полную власть добиваться своих целей. Вы верите в это безоговорочно."))

/obj/item/card/id/foundation/attack_self(mob/living/user)
	. = ..()
	if(istype(user))
		for(var/mob/M in viewers(world.view, get_turf(user))-user)
			if(user.psi && isliving(M))
				var/mob/living/L = M
				if(!L.psi)
					to_chat(L, SPAN_NOTICE("Это реальная сделка, скрепленная печатью [GLOB.using_map.boss_name]. Это дает владельцу полную власть добиваться своих целей. Вы доверяете \the [user]."))
					continue
			to_chat(M, SPAN_WARNING("Существует псионическое принуждение, окружающее \the [src] в мерцании неописуемого света."))

/obj/item/card/id/foundation/on_update_icon()
	return

/obj/item/card/id/foundation/New()
	..()
	access |= get_all_station_access()

/obj/item/card/id/all_access
	name = "\improper Запасной идентификатор администратора"
	desc = "Запасное удостоверение личности самого Лорда Лордов."
	registered_name = "Administrator"
	assignment = "Administrator"
	detail_color = COLOR_MAROON
	extra_details = list("goldstripe")

/obj/item/card/id/all_access/New()
	access = get_access_ids()
	..()

// Department-flavor IDs
/obj/item/card/id/medical
	name = "идентификационная карта"
	desc = "Карточка, выданная медицинскому персоналу."
	job_access_type = /datum/job/doctor
	detail_color = COLOR_PALE_BLUE_GRAY

/obj/item/card/id/medical/chemist
	job_access_type = /datum/job/chemist

/obj/item/card/id/medical/geneticist
	job_access_type = /datum/job/geneticist

/obj/item/card/id/medical/psychiatrist
	job_access_type = /datum/job/psychiatrist

/obj/item/card/id/medical/paramedic
	job_access_type = /datum/job/Paramedic

/obj/item/card/id/medical/head
	name = "идентификационная карта"
	desc = "Открытка, олицетворяющая заботу и сострадание."
	job_access_type = /datum/job/cmo
	extra_details = list("goldstripe")

/obj/item/card/id/security
	name = "идентификационная карта"
	desc = "Карточка, выданная сотрудникам службы безопасности."
	job_access_type = /datum/job/officer
	color = COLOR_OFF_WHITE
	detail_color = COLOR_MAROON

/obj/item/card/id/security/warden
	job_access_type = /datum/job/warden

/obj/item/card/id/security/detective
	job_access_type = /datum/job/detective

/obj/item/card/id/security/head
	name = "идентификационная карта"
	desc = "Карточка, олицетворяющая честь и защиту."
	job_access_type = /datum/job/hos
	extra_details = list("goldstripe")

/obj/item/card/id/engineering
	name = "идентификационная карта"
	desc = "Карточка, выдаваемая инженерному персоналу."
	job_access_type = /datum/job/engineer
	detail_color = COLOR_SUN

/obj/item/card/id/engineering/head
	name = "идентификационная карта"
	desc = "Карточка, олицетворяющая креативность и изобретательность."
	job_access_type = /datum/job/chief_engineer
	extra_details = list("goldstripe")

/obj/item/card/id/science
	name = "идентификационная карта"
	desc = "Карточка, выданная научному персоналу."
	job_access_type = /datum/job/scientist
	detail_color = COLOR_PALE_PURPLE_GRAY

/obj/item/card/id/science/xenobiologist
	job_access_type = /datum/job/xenobiologist

/obj/item/card/id/science/roboticist
	job_access_type = /datum/job/roboticist

/obj/item/card/id/science/head
	name = "идентификационная карта"
	desc = "Карта, олицетворяющая знания и рассуждения."
	job_access_type = /datum/job/rd
	extra_details = list("goldstripe")

/obj/item/card/id/cargo
	name = "идентификационная карта"
	desc = "Карточка, выданная грузовому персоналу."
	job_access_type = /datum/job/cargo_tech
	detail_color = COLOR_BROWN

/obj/item/card/id/cargo/mining
	job_access_type = /datum/job/mining

/obj/item/card/id/cargo/head
	name = "идентификационная карта"
	desc = "Карта, которая представляет услуги и планирование."
	job_access_type = /datum/job/qm
	extra_details = list("goldstripe")

/obj/item/card/id/civilian
	name = "идентификационная карта"
	desc = "Карта, выданная гражданскому персоналу."
	job_access_type = DEFAULT_JOB_TYPE
	detail_color = COLOR_CIVIE_GREEN

/obj/item/card/id/civilian/chef
	job_access_type = /datum/job/chef

/obj/item/card/id/civilian/botanist
	job_access_type = /datum/job/hydro

/obj/item/card/id/civilian/janitor
	job_access_type = /datum/job/janitor

/obj/item/card/id/civilian/librarian
	job_access_type = /datum/job/librarian

/obj/item/card/id/civilian/internal_affairs_agent
	job_access_type = /datum/job/lawyer
	detail_color = COLOR_NAVY_BLUE

/obj/item/card/id/civilian/chaplain
	job_access_type = /datum/job/chaplain

/obj/item/card/id/civilian/head //This is not the HoP. There's no position that uses this right now.
	name = "идентификационная карта"
	desc = "Карта, олицетворяющая здравый смысл и ответственность."
	extra_details = list("goldstripe")

/obj/item/card/id/merchant
	name = "идентификационная карта"
	desc = "Карточка, выдаваемая продавцам, указывающая на их право продавать и покупать товары."
	access = list(access_merchant)
	color = COLOR_OFF_WHITE
	detail_color = COLOR_BEIGE
