/**************
 * NSV sierra *
 **************/
GLOBAL_VAR_CONST(access_hangar, "ACCESS_HANGAR")
/datum/access/hangar
	id = GLOB.access_hangar
	desc = "Hangar Deck"
	region = ACCESS_REGION_GENERAL

GLOBAL_VAR_CONST(access_petrov, "ACCESS_PETROV")
/datum/access/petrov
	id = GLOB.access_petrov
	desc = "Petrov"
	region = ACCESS_REGION_RESEARCH

GLOBAL_VAR_CONST(access_petrov_helm, "ACCESS_PETROV_HELM")
/datum/access/petrov_helm
	id = GLOB.access_petrov_helm
	desc = "Petrov Helm"
	region = ACCESS_REGION_RESEARCH

GLOBAL_VAR_CONST(access_guppy_helm, "ACCESS_GUPPY_HELM")
/datum/access/guppy_helm
	id = GLOB.access_guppy_helm
	desc = "General Utility Pod Helm"
	region = ACCESS_REGION_SUPPLY

GLOBAL_VAR_CONST(access_expedition_shuttle_helm, "ACCESS_EXPEDITION_SHUTTLE_HELM")
/datum/access/exploration_shuttle_helm
	id = GLOB.access_expedition_shuttle_helm
	desc = "Charon Helm"
	region = ACCESS_REGION_RESEARCH

GLOBAL_VAR_CONST(access_iaa, "ACCESS_IAA")
/datum/access/iaa
	id = GLOB.access_iaa
	desc = "Internal Affairs Agent"
	region = ACCESS_REGION_COMMAND
	access_type = ACCESS_TYPE_NONE // Ruler of their own domain, Captain and RD cannot enter

GLOBAL_VAR_CONST(access_gun, "ACCESS_GUN")
/datum/access/gun
	id = GLOB.access_gun
	desc = "BSA Cannon"
	region = ACCESS_REGION_COMMAND

GLOBAL_VAR_CONST(access_expedition_shuttle, "ACCESS_EXPEDITION_SHUTTLE")
/datum/access/exploration_shuttle
	id = GLOB.access_expedition_shuttle
	desc = "Charon"
	region = ACCESS_REGION_RESEARCH

GLOBAL_VAR_CONST(access_guppy, "ACCESS_GUPPY")
/datum/access/guppy
	id = GLOB.access_guppy
	desc = "General Utility Pod"
	region = ACCESS_REGION_SUPPLY

GLOBAL_VAR_CONST(access_seneng, "ACCESS_SENENG")
/datum/access/seneng
	id = GLOB.access_seneng
	desc = "Senior Engineer"
	region = ACCESS_REGION_ENGINEERING

GLOBAL_VAR_CONST(access_senmed, "ACCESS_SENMED")
/datum/access/senmed
	id = GLOB.access_senmed
	desc = "Physician"
	region = ACCESS_REGION_MEDBAY

GLOBAL_VAR_CONST(access_guard, "ACCESS_GUARD")
/datum/access/guard
	id = GLOB.access_guard
	desc = "Guard Equipment"
	region = ACCESS_REGION_SECURITY

GLOBAL_VAR_CONST(access_explorer, "ACCESS_EXPLORER")
/datum/access/explorer
	id = GLOB.access_explorer
	desc = "Explorer"
	region = ACCESS_REGION_RESEARCH

GLOBAL_VAR_CONST(access_el, "ACCESS_EL")
/datum/access/el
	id = GLOB.access_el
	desc = "Exploration Leader"
	region = ACCESS_REGION_COMMAND

GLOBAL_VAR_CONST(access_seceva, "ACCESS_SECEVA")
/datum/access/seceva
	id = GLOB.access_seceva
	desc = "Security EVA"
	region = ACCESS_REGION_SECURITY

GLOBAL_VAR_CONST(access_commissary, "ACCESS_COMMISSARY")
/datum/access/commissary
	id = GLOB.access_commissary
	desc = "Commissary"
	region = ACCESS_REGION_GENERAL
GLOBAL_VAR_CONST(access_warden, "ACCESS_WARDEN")
/datum/access/warden
	id = GLOB.access_warden
	desc = "Warden"
	region = ACCESS_REGION_SECURITY

GLOBAL_VAR_CONST(access_actor, "ACCESS_ACTOR")
/datum/access/actor
	id = GLOB.access_actor
	desc = "Actor"
	region = ACCESS_REGION_GENERAL

GLOBAL_VAR_CONST(access_field_eng, "ACCESS_FIELD_ENG")
/datum/access/field_eng
	id = GLOB.access_field_eng
	desc = "Field Engineer"
	region = ACCESS_REGION_RESEARCH

GLOBAL_VAR_CONST(access_field_med, "ACCESS_FIELD_MED")
/datum/access/field_med
	id = GLOB.access_field_med
	desc = "Field Medic"
	region = ACCESS_REGION_RESEARCH

GLOBAL_VAR_CONST(access_bar, "ACCESS_BAR")
/datum/access/bar
	id = GLOB.access_bar
	desc = "Bar"
	region = ACCESS_REGION_GENERAL

GLOBAL_VAR_CONST(access_chief_steward, "ACCESS_SIERRA_CHIEF_STEWARD")
/datum/access/chief_steward
	id = GLOB.access_chief_steward
	desc = "Chief Steward"
	region = ACCESS_REGION_GENERAL

/datum/access/network
	region = ACCESS_REGION_COMMAND
