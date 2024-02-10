GLOBAL_DATUM_INIT(renegades, /datum/antagonist/renegade, new)

/datum/antagonist/renegade
	role_text = "Ренегат"
	role_text_plural = "Ренегаты"
	blacklisted_jobs = list(/datum/job/ai, /datum/job/submap)
	restricted_jobs = list(/datum/job/officer, /datum/job/warden, /datum/job/captain, /datum/job/hop, /datum/job/hos, /datum/job/chief_engineer, /datum/job/rd, /datum/job/cmo)
	welcome_text = "Сегодня что-то ЯВНО пойдет не так, ты просто это чувствуешь. Ты параноик, у тебя есть пистолет, пару грамм космо-дури и твердая уверенность что ты выживешь."
	antag_text = {"\
	<p>Вы <b>второстепенный</b> антагонист! Убедитесь, что <b>вы</b> выживите до конца раунда любой ценой.</p> \
	<p>Предавайте друзей, заключайте сделки с врагами и держите пистолет под рукой. \
	Вы тут не для поиска проблем на свою задницу - но есть <i>ОНИ</i> найдут <i>ВАС</i> сами, пустите их в расход.</p> \
	<p>Помните, что правила по-прежнему распространяются на антагонистов. Прежде чем предпринимать крайние меры, пообщайтесь с администрацией.</p>
	"}

	id = MODE_RENEGADE
	flags = ANTAG_SUSPICIOUS | ANTAG_IMPLANT_IMMUNE | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	hard_cap = 3
	hard_cap_round = 5

	initial_spawn_req = 1
	initial_spawn_target = 3
	antaghud_indicator = "hud_renegade"
	skill_setter = /datum/antag_skill_setter/station/renegade

	var/list/spawn_guns = list(
		/obj/item/gun/energy/retro,
		/obj/item/gun/energy/gun,
		/obj/item/gun/energy/crossbow,
		/obj/item/gun/energy/pulse_rifle/pistol,
		/obj/item/gun/projectile/automatic,
		/obj/item/gun/projectile/automatic/machine_pistol,
		/obj/item/gun/projectile/automatic/sec_smg,
		/obj/item/gun/projectile/pistol/magnum_pistol,
		/obj/item/gun/projectile/pistol/sec/lethal,
		/obj/item/gun/projectile/pistol/holdout,
		/obj/item/gun/projectile/revolver,
		/obj/item/gun/projectile/revolver/medium,
		/obj/item/gun/projectile/shotgun/doublebarrel/sawn,
		/obj/item/gun/projectile/pistol/magnum_pistol,
		/obj/item/gun/projectile/revolver/holdout,
		/obj/item/gun/projectile/pistol/throwback,
		/obj/item/gun/energy/xray/pistol,
		/obj/item/gun/energy/toxgun,
		/obj/item/gun/energy/incendiary_laser,
		/obj/item/gun/projectile/pistol/magnum_pistol
		)

/datum/antagonist/renegade/create_objectives(datum/mind/player)

	if(!..())
		return

	var/datum/objective/survive/survive = new
	survive.owner = player
	player.objectives |= survive

/datum/antagonist/renegade/equip(mob/living/carbon/human/player)

	if(!..())
		return

	var/gun_type = pick(spawn_guns)
	if(islist(gun_type))
		gun_type = pick(gun_type)
	var/obj/item/gun = new gun_type(get_turf(player))

	// Attempt to put into a container.
	if(player.equip_to_storage(gun))
		return

	// If that failed, attempt to put into any valid non-handslot
	if(player.equip_to_appropriate_slot(gun))
		return

	// If that failed, then finally attempt to at least let the player carry the weapon
	player.put_in_hands(gun)


/proc/rightandwrong()
	to_chat(usr, "<B>Вы вызвали оружие!</B>")
	message_admins("[key_name_admin(usr, 1)] вызвал оружие!")
	for(var/mob/living/carbon/human/H in GLOB.player_list)
		if(H.stat == 2 || !(H.client)) continue
		if(is_special_character(H)) continue
		GLOB.renegades.add_antagonist(H.mind)
