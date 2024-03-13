/// True when this atom can be used as a cable coil.
/atom/proc/IsCoil()
	return FALSE

/// Defines the base coil as useable as a cable coil.
/obj/item/stack/cable_coil/IsCoil()
	return TRUE

/// True when A exists and can be used as a cable coil.
#define isCoil(A) (A?.IsCoil())

/// True when this atom can be used as a hatchet.
/atom/proc/IsHatchet()
	return FALSE

/// Defines the base hatchet as useable as a hatchet.
/obj/item/material/hatchet/IsHatchet()
	return TRUE

/// True when A exists and can be used as a hatchet.
#define isHatchet(A) (A?.IsHatchet())


/// True when this atom can be used as a flame source. This is for open flames.
/atom/proc/IsFlameSource()
	return FALSE

/// True when A exists and can be used as a flame source.
#define isFlameSource(A) (A?.IsFlameSource())


/**
 * Returns an integer value of temperature when this atom can be used as a heat source. This is for hot objects.
 *
 * Defaults to `1000` if `IsFlameSource()` returns `TRUE`, otherwise `0`.
 */
/atom/proc/IsHeatSource()
	return IsFlameSource() ? 1000 : 0

/// 0 if A does not exist, or the heat value of A
#define isHeatSource(A) (A ? A.IsHeatSource() : 0)


/// True when A exists and is either a flame or heat source
#define isFlameOrHeatSource(A) (A && (A.IsFlameSource() || !!A.IsHeatSource()))
