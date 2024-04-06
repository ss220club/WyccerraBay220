/// From base of /client/Move(): (list/move_args)
#define COMSIG_MOB_CLIENT_PRE_LIVING_MOVE "mob_client_pre_living_move"
	/// Should we stop the current living movement attempt
	#define COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE COMPONENT_MOVABLE_BLOCK_PRE_MOVE

/// From base of /mob/UpdateLyingBuckledAndVerbStatus()
#define COMSIG_MOB_UPDATE_LYING_BUCKLED_VERBSTATUS "mob_update_lying_buckled_verbstatus"

/// from mob/CanPass(): (atom/movable/mover, turf/target, height, air_group)
#define COMSIG_MOB_CAN_PASS "mob_can_pass"
	#define COMPONENT_MOB_PASSABLE FLAG(0)

///from base of mob/ranged_attack(): (/atom, modifiers)
#define COMSIG_MOB_ATTACK_RANGED "mob_attack_ranged"
///from base of mob/ranged_attack_secondary(): (/atom, modifiers)
#define COMSIG_MOB_ATTACK_RANGED_SECONDARY "mob_attack_ranged_secondary"

///from base of proc/examinate(): (/atom, list/examine_strings)
#define COMSIG_MOB_EXAMINING "mob_examining"
///from base of proc/examinate(): (/atom)
#define COMSIG_MOB_EXAMINATE "mob_examinate"
