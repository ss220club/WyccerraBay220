// Atom movable signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

///from base of atom/movable/Moved(): (/atom)
#define COMSIG_MOVABLE_PRE_MOVE "movable_pre_move"
	#define COMPONENT_MOVABLE_BLOCK_PRE_MOVE FLAG(0)

///from base of atom/movable/Moved(): (atom/old_loc, forced)
#define COMSIG_MOVABLE_MOVED "movable_moved"
