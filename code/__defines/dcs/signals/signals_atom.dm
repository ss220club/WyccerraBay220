// Main atom signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /atom signals

///from base of atom/Entered(): (atom/movable/arrived, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERED "atom_entered"
/// Sent from the atom that just Entered src. From base of atom/Entered(): (/atom/destination, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERING "atom_entering"

//from base of atom/change_tts_seed(): (mob/chooser, override, fancy_voice_input_tgui)
#define COMSIG_ATOM_TTS_SEED_CHANGE "atom_tts_seed_change"
//called for tts_component: (atom/speaker, mob/listener, message, atom/location, is_local, effect, traits, preSFX, postSFX)
#define COMSIG_ATOM_TTS_CAST "atom_tts_cast"
//from base of atom/tts_trait_add(): (atom/user, trait)
#define COMSIG_ATOM_TTS_TRAIT_ADD "atom_tts_trait_add"
//from base of atom/tts_trait_remove(): (atom/user, trait)
#define COMSIG_ATOM_TTS_TRAIT_REMOVE "atom_tts_trait_remove"
