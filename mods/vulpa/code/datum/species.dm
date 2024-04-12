/datum/species/vulpkanin
	name = SPECIES_VULPKANIN
	name_plural = SPECIES_VULPKANIN
	icobase = 'mods/vulpa/icons/vulpa_body/body.dmi'
	deform =  'mods/vulpa/icons/vulpa_body/deformed_body.dmi'
	preview_icon = 'mods/vulpa/icons/vulpa_body/preview.dmi'
	tail = "vulptail"
	tail_animation = 'mods/vulpa/icons/vulpa_body/tail.dmi'
	default_head_hair_style = "Clean Cut"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick, /datum/unarmed_attack/claws, /datum/unarmed_attack/punch, /datum/unarmed_attack/bite/sharp)

	darksight_range = 7
	darksight_tint = DARKTINT_GOOD
	slowdown = -0.5
	brute_mod = 1.15
	burn_mod =  1.15
	flash_mod = 1.5
	hunger_factor = DEFAULT_HUNGER_FACTOR * 1.5

	gluttonous = GLUT_TINY
	hidden_from_codex = FALSE
	health_hud_intensity = 1.75

	min_age = 14
	max_age = 80

	description = "Вульпканин — вид гуманоидных собакоподобных организмов. Вульпканин происходит с планеты Альтам, которая долгое время находится в стадии кровопролитной войны. \
	В силу того, что вульпкане окончательно не оформились в единственное государство, они представляют из себя децентрализованное скопление кланов.<br/><br/> \
	Сотни тысяч беженцев-вульпканинов заполонили всю галактику, от колоний и до государств."

	cold_level_1 = 200 //Default 260
	cold_level_2 = 140 //Default 200
	cold_level_3 = 80  //Default 120

	heat_level_1 = 330 //Default 360
	heat_level_2 = 380 //Default 400
	heat_level_3 = 800 //Default 1000

	heat_discomfort_level = 292
	heat_discomfort_strings = list(
		"Ваша шерсть колется от жары.",
		"Вы чувствуйте некомфортное тепло.",
		"Ваша перегретая кожа чешется."
		)
	cold_discomfort_level = 230

	//primitive_form = "Vulpin"
	//primitive_form = /datum/species/monkey/vulpkanin

	default_emotes = list(
		/singleton/emote/human/swish,
		/singleton/emote/human/wag,
		/singleton/emote/human/sway,
		/singleton/emote/human/qwag,
		/singleton/emote/human/fastsway,
		/singleton/emote/human/swag,
		/singleton/emote/human/stopsway
		)

	spawn_flags = SPECIES_CAN_JOIN | SPECIES_IS_WHITELISTED
	appearance_flags = SPECIES_APPEARANCE_HAS_HAIR_COLOR | SPECIES_APPEARANCE_HAS_LIPS | SPECIES_APPEARANCE_HAS_UNDERWEAR | SPECIES_APPEARANCE_HAS_SKIN_COLOR | SPECIES_APPEARANCE_HAS_EYE_COLOR

	flesh_color = "#b9b3ae"
	base_color = "#817f7f"
	blood_color = "#862a51"
	organs_icon = 'mods/tajara/icons/tajara_body/organs.dmi'

	move_trail = /obj/decal/cleanable/blood/tracks/paw

	sexybits_location = BP_GROIN

	available_cultural_info = list(
		TAG_CULTURE =   list(
			CULTURE_VULPKANIN
		),
		TAG_HOMEWORLD = list(
			HOME_SYSTEM_ALTAM
		),
		TAG_FACTION = list(
			FACTION_VULPKANIN_REFUGEES,
			FACTION_VULPKANIN_RAHT,
			FACTION_VULPKANIN_MZMANULINA,
			FACTION_VULPKANIN_ASHTARA
		),
		TAG_RELIGION =  list(
			RELIGION_SPIRITUALISM,
			RELIGION_JUDAISM,
			RELIGION_HINDUISM,
			RELIGION_BUDDHISM,
			RELIGION_ISLAM,
			RELIGION_CHRISTIANITY,
			RELIGION_AGNOSTICISM,
			RELIGION_DEISM,
			RELIGION_THELEMA,
			RELIGION_ATHEISM,
			RELIGION_OTHER
		)
	)

/obj/item/organ/internal/eyes/vulp
	name = "vulp eyes"

/mob/living/carbon/human/vulpkanin/Initialize(mapload)
	head_hair_style = "Clean Cut"
	. = ..(mapload, SPECIES_VULPKANIN)
