// Main atom signals. Format:
// When the signal is called: (signal arguments)
// All signals send the source datum of the signal as the first argument

// /atom signals

///from base of atom/Entered(): (atom/movable/arrived, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERED "atom_entered"
/// Sent from the atom that just Entered src. From base of atom/Entered(): (/atom/destination, atom/old_loc, list/atom/old_locs)
#define COMSIG_ATOM_ENTERING "atom_entering"
