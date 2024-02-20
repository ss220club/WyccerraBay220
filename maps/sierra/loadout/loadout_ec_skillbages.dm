/datum/gear/skill
	category = GEAR_CATEGORY_SKILL_BADGES
	abstract_type = /datum/gear/skill
	slot = slot_tie

/datum/gear/skill/botany
	display_name = "Field Xenobotany Specialist badge"
	path = /obj/item/clothing/accessory/solgov/skillbadge/botany
	required_skills = list(SKILL_BOTANY = SKILL_TRAINED)

/datum/gear/skill/botany/stripe
	display_name = "Field Xenobotany Specialist voidsuit stripe"
	path = /obj/item/clothing/accessory/solgov/skillstripe/botany

/datum/gear/skill/netgun
	display_name = "Xenofauna Acquisition Specialist badge"
	path = /obj/item/clothing/accessory/solgov/skillbadge/netgun
	required_skills = list(SKILL_WEAPONS = SKILL_TRAINED)

/datum/gear/skill/netgun/stripe
	display_name = "Xenofauna Acquisition Specialist voidsuit stripe"
	path = /obj/item/clothing/accessory/solgov/skillstripe/netgun

/datum/gear/skill/eva
	display_name = "Void Mobility Specialist badge"
	path = /obj/item/clothing/accessory/solgov/skillbadge/eva
	required_skills = list(SKILL_EVA = SKILL_TRAINED)

/datum/gear/skill/eva/stripe
	display_name = "Void Mobility Specialist voidsuit stripe"
	path = /obj/item/clothing/accessory/solgov/skillstripe/eva

/datum/gear/skill/medical
	display_name = "Advanced First Aid Specialist badge"
	path = /obj/item/clothing/accessory/solgov/skillbadge/medical
	required_skills = list(SKILL_MEDICAL = SKILL_BASIC)

/datum/gear/skill/medical/stripe
	display_name = "Advanced First Aid Specialist voidsuit stripe"
	path = /obj/item/clothing/accessory/solgov/skillstripe/medical

/datum/gear/skill/mech
	display_name = "Exosuit Specialist badge"
	path = /obj/item/clothing/accessory/solgov/skillbadge/mech
	required_skills = list(SKILL_MECH = HAS_PERK)

/datum/gear/skill/electric
	display_name = "Electrical Specialist badge"
	path = /obj/item/clothing/accessory/solgov/skillbadge/electric
	required_skills = list(SKILL_ELECTRICAL = SKILL_TRAINED)

/datum/gear/skill/electric/stripe
	display_name = "Electrical Specialist voidsuit stripe"
	path = /obj/item/clothing/accessory/solgov/skillstripe/electric

/datum/gear/skill/science
	display_name = "Research Specialist badge"
	path = /obj/item/clothing/accessory/solgov/skillbadge/science
	required_skills = list(SKILL_SCIENCE = SKILL_TRAINED)
