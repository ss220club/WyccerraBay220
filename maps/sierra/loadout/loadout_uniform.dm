/datum/gear/uniform/utility
	display_name = "utility uniform"
	path = /obj/item/clothing/under/solgov/utility

/datum/gear/uniform/roboticist_skirt
	allowed_roles = list(/datum/job/roboticist)

/datum/gear/uniform/sterile
	allowed_roles = STERILE_ROLES

/datum/gear/uniform/hazard
	allowed_roles = TECHNICAL_ROLES

/* SIERRA TODO: watch for contractors uniforms, may be in mods
/datum/gear/uniform/corpsi
	display_name = "contractor uniform selection"
	path = /obj/item/clothing/under/solgov/utility
	allowed_branches = list(/datum/mil_branch/contractor)
*/

/datum/gear/uniform/si_guard
	display_name = "Nanotrasen guard uniform"
	path = /obj/item/clothing/under/rank/guard/nanotrasen
	allowed_roles = list(/datum/job/officer)

/datum/gear/uniform/si_exec
	display_name = "Nanotrasen senior researcher alt uniform"
	path = /obj/item/clothing/under/rank/scientist/executive/nanotrasen
	allowed_roles = list(/datum/job/senior_scientist)

/datum/gear/uniform/si_overalls
	display_name = "corporate coveralls"
	path = /obj/item/clothing/under/rank/ntwork
	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/contractor)

/datum/gear/uniform/si_overalls/New()
	..()
	var/overalls = list()
	overalls["NT beige and red coveralls"]			= /obj/item/clothing/under/rank/ntwork/nanotrasen
	overalls["Hephaestus grey and cyan coveralls"]	= /obj/item/clothing/under/rank/ntwork/heph
	gear_tweaks += new/datum/gear_tweak/path(overalls)

/datum/gear/uniform/si_flight
	display_name = "corporate pilot suit"
	path = /obj/item/clothing/under/rank/ntpilot
	allowed_branches = list(/datum/mil_branch/employee, /datum/mil_branch/contractor)

/datum/gear/uniform/si_flight/New()
	..()
	var/flight = list()
	flight["NT red flight suit"]			= /obj/item/clothing/under/rank/ntpilot/nanotrasen
	flight["Hephaestus cyan flight suit"]	= /obj/item/clothing/under/rank/ntpilot/heph
	gear_tweaks += new/datum/gear_tweak/path(flight)

/datum/gear/uniform/si_exec_jacket
	display_name = "Nanotrasen liason suit"
	path = /obj/item/clothing/under/suit_jacket/corp/nanotrasen
	allowed_roles = list(/datum/job/iaa)

/datum/gear/uniform/formal_shirt_and_pants
	display_name = "formal shirts with pants"
	path = /obj/item/clothing/under/suit_jacket

/datum/gear/uniform/formal_shirt_and_pants/New()
	..()
	var/list/shirts = list()
	shirts += /obj/item/clothing/under/suit_jacket/charcoal
	shirts += /obj/item/clothing/under/suit_jacket/navy
	shirts += /obj/item/clothing/under/suit_jacket/burgundy
	shirts += /obj/item/clothing/under/suit_jacket/checkered
	gear_tweaks += new/datum/gear_tweak/path/specified_types_list(shirts)

/datum/gear/uniform/retro_security
	display_name = "retro security officer's uniform"
	allowed_roles = SECURITY_ROLES
	path = /obj/item/clothing/under/retro/security

/datum/gear/uniform/retro_medical
	display_name = "retro medical officer's uniform"
	allowed_roles = STERILE_ROLES
	path = /obj/item/clothing/under/retro/medical

/datum/gear/uniform/retro_engineering
	display_name = "retro engineering uniform"
	allowed_roles = TECHNICAL_ROLES
	path = /obj/item/clothing/under/retro/engineering

/datum/gear/uniform/retro_science
	display_name = "retro science officer's uniform"
	allowed_roles = RESEARCH_ROLES
	path = /obj/item/clothing/under/retro/science

/datum/gear/suit/unathi/officer_uniform
	allowed_roles = SECURITY_ROLES
