/// from base of /obj/item/gun/toggle_safety(): (safety_state)
#define COMSIG_GUN_TOGGLE_SAFETY "gun_toggle_safety"

/// from base of /obj/item/change_tool_behaviour(): (new_tool_behaviour, new_toolspeed, override_sound)
#define COMSIG_OBJ_CHANGE_TOOL_BEHAVIOUR "obj_change_tool_behaviour"

///from base of [/obj/item/proc/tool_check_callback]: (mob/living/user)
#define COMSIG_TOOL_IN_USE "tool_in_use"
///from base of [/obj/item/proc/tool_start_check]: (mob/living/user)
#define COMSIG_TOOL_START_USE "tool_start_use"

///from base of atom/use_before(): (/atom, /mob/living, params)
#define COMSIG_ITEM_USE_BEFORE "item_use_before"
///from base of atom/use_after(): (/atom, /mob/living, params)
#define COMSIG_ITEM_USE_AFTER "item_use_after"
///from base of atom/use_after_secondary(): (/atom, /mob/living, params)
#define COMSIG_ITEM_USE_AFTER_SECONDARY "item_use_after_secondary"
///from base of atom/afterattack(): (/atom, /mob/living, proximity, params)
#define COMSIG_ITEM_AFTERATTACK "item_afterattack_secondary"
///from base of atom/afterattack_secondary(): (/atom, /mob/living, proximity, params)
#define COMSIG_ITEM_AFTERATTACK_SECONDARY "item_afterattack_secondary"
	#define COMPONENT_SECONDARY_CANCEL_ATTACK_CHAIN FLAG(0)
	#define COMPONENT_SECONDARY_CONTINUE_ATTACK_CHAIN FLAG(1)
	#define COMPONENT_SECONDARY_CALL_NORMAL_ATTACK_CHAIN FLAG(2)
