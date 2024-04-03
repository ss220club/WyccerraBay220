// Main atom signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /atom signals

//from SSatoms InitAtom - Only if the  atom was not deleted or failed initialization
#define COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZE "atom_init_success"

///from base of atom/Entered(): (atom/movable/arrived, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERED "atom_entered"
/// Sent from the atom that just Entered src. From base of atom/Entered(): (/atom/destination, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERING "atom_entering"

///from base of atom/change_tts_seed(): (mob/chooser, override, new_traits)
#define COMSIG_ATOM_TTS_SEED_CHANGE "atom_tts_seed_change"
///from base of atom/cast_tts: (mob/listener, message, atom/location, is_local, effect, traits, preSFX, postSFX)
#define COMSIG_ATOM_TTS_CAST "atom_tts_cast"
///from base of atom/tts_trait_add(): (trait)
#define COMSIG_ATOM_TTS_TRAIT_ADD "atom_tts_trait_add"
///from base of atom/tts_trait_remove(): (trait)
#define COMSIG_ATOM_TTS_TRAIT_REMOVE "atom_tts_trait_remove"

/// Sent from [atom/proc/item_interaction], when this atom is left-clicked on by a mob with an item
/// Sent from the very beginning of the click chain, intended for generic atom-item interactions
/// Args: (mob/living/user, obj/item/tool, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_ITEM_INTERACTION "atom_item_interaction"
/// Sent from [atom/proc/item_interaction], when this atom is right-clicked on by a mob with an item
/// Sent from the very beginning of the click chain, intended for generic atom-item interactions
/// Args: (mob/living/user, obj/item/tool, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_ITEM_INTERACTION_SECONDARY "atom_item_interaction_secondary"
/// Sent from [atom/proc/item_interaction], to an item clicking on an atom
/// Args: (mob/living/user, atom/interacting_with, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ITEM_INTERACTING_WITH_ATOM "item_interacting_with_atom"
/// Sent from [atom/proc/item_interaction], to an item right-clicking on an atom
/// Args: (mob/living/user, atom/interacting_with, list/modifiers)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ITEM_INTERACTING_WITH_ATOM_SECONDARY "item_interacting_with_atom_secondary"
/// Sent from [atom/proc/item_interaction], when this atom is left-clicked on by a mob with a tool of a specific tool type
/// Args: (mob/living/user, obj/item/tool)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_TOOL_ACT(tooltype) "tool_act_[tooltype]"
/// Sent from [atom/proc/item_interaction], when this atom is right-clicked on by a mob with a tool of a specific tool type
/// Args: (mob/living/user, obj/item/tool)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_SECONDARY_TOOL_ACT(tooltype) "tool_secondary_act_[tooltype]"
/// Sent from [atom/proc/item_interaction], when the interaction is complete. Use it as "post-act"
/// Args: (mob/living/user, obj/item/tool, act_result)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_TOOL_ACT_RESULT(tooltype) "tool_act_result_[tooltype]"
/// Sent from [atom/proc/item_interaction], when the interaction has failed (no act_result)
/// Args: (mob/living/user, obj/item/tool)
/// Return any ITEM_INTERACT_ flags as relevant (see tools.dm)
#define COMSIG_ATOM_TOOL_ACT_EMPTY "tool_act_empty"

// Notifies tools that something is happening.
// Sucessful actions against an atom.
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_PRIMARY(tooltype) "tool_atom_acted_[tooltype]"
///Called from /atom/proc/tool_act (atom)
#define COMSIG_TOOL_ATOM_ACTED_SECONDARY(tooltype) "tool_atom_acted_[tooltype]"

///from base of atom/examine(): (/mob, list/examine_text)
#define COMSIG_ATOM_EXAMINE "atom_examine"
