// Atom attack signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/attackby(): (/obj/item, /mob/living, params)
#define COMSIG_ATOM_ATTACKBY "atom_attackby"
///from base of atom/can_use_item(): (/obj/item, /mob/living, params)
#define COMSIG_ATOM_CAN_USE_ITEM "atom_can_use_item"
///from base of atom/use_tool(): (/obj/item, /mob/living, params)
#define COMSIG_ATOM_USE_TOOL "atom_use_tool"
///from base of atom/use_tool_secondary(): (/obj/item, /mob/living, params)
#define COMSIG_ATOM_USE_TOOL_SECONDARY "atom_use_tool_secondary"
///from base of atom/use_weapon(): (/obj/item, /mob/living, params)
#define COMSIG_ATOM_USE_WEAPON "atom_use_weapon"
///from base of atom/use_weapon_secondary(): (/obj/item, /mob/living, params)
#define COMSIG_ATOM_USE_WEAPON_SECONDARY "atom_use_weapon_secondary"
///from base of atom/attack_hand(): (mob/user, list/modifiers)
#define COMSIG_ATOM_ATTACK_HAND "atom_attack_hand"
///from base of atom/attack_hand_secondary(): (mob/user, list/modifiers)
#define COMSIG_ATOM_ATTACK_HAND_SECONDARY "atom_attack_hand_secondary"
///from base of atom/animal_attack(): (/mob/user)
#define COMSIG_ATOM_ATTACK_ANIMAL "attack_animal"
///from base of atom/attack_robot(): (mob/user)
#define COMSIG_ATOM_ATTACK_ROBOT "atom_attack_robot"
///from base of atom/attack_robot_secondary(): (mob/user)
#define COMSIG_ATOM_ATTACK_ROBOT_SECONDARY "atom_attack_robot_secondary"

/* Attack signals. They should share the returned flags, to standardize the attack chain. */
/// tool_act -> pre_attack -> target.attackby (item.attack) -> afterattack
	///Ends the attack chain. If sent early might cause posterior attacks not to happen.
	#define COMPONENT_CANCEL_ATTACK_CHAIN FLAG(0)
	///Skips the specific attack step, continuing for the next one to happen.
	#define COMPONENT_SKIP_ATTACK FLAG(1)
