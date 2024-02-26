/// Simple macro wrapper for BYOND proc `icon_states`, but with use of cache
/// Checkout `code/datums/repositories/icon_states.dm` for details
/// Should be used instead of `icon_states`
#define ICON_STATES(icon) GLOB.icon_states_repository.get_icon_states(icon)

/// Helper to efficiently check if passed `icon_state` is in `icon`
#define ICON_HAS_STATE(icon, icon_state) GLOB.icon_states_repository.icon_has_state(icon, icon_state)

/// Helper to efficiently check if passed `icon_state` is in list of `icons`
#define ANY_ICON_HAS_STATE(icons, icon_state) GLOB.icon_states_repository.any_icon_has_state(icons, icon_state)

/// Helper to efficiently check if passed icon has any states
#define ICON_IS_EMPTY(icon) GLOB.icon_states_repository.is_icon_empty(icon)
