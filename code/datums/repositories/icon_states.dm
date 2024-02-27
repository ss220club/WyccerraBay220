GLOBAL_DATUM_INIT(icon_states_repository, /repository/icon_states, new)

/// Repository used as cache for `icon_states` of specific `icon`
/repository/icon_states
	VAR_PRIVATE/list/icon_to_icon_states = list()


/*
 * Tries to find `icon_states` for `icons` in cache first,
 * if none - new cache entry for `icon` is generated.
 *
 ** Returns: Copy of icon states cache, so it's safe to modify it.
 */
/repository/icon_states/proc/get_icon_states(list/icons)
	if(!islist(icons))
		icons = list(icons)

	var/list/icon_states = list()
	for(var/icon in icons)
		var/list/cached_icon_states = get_cached_icon_states(icon)
		for(var/icon_state in cached_icon_states)
			icon_states += icon_state

	return icon_states

/*
 * Checks if passed icon has any icon states. Null `icon` is forbidden and will cause runtime
 *
 ** Returns: TRUE if any icon state is present in icon, FALSE otherwise.
 */
/repository/icon_states/proc/is_icon_empty(icon)
	ASSERT(icon)

	return !!length(get_cached_icon_states(icon))

/*
 * Checks if the `icon_state` is in `icon`
 *
 ** Returns: TRUE if `icon_state` is present in icon, FALSE otherwise.
 */
/repository/icon_states/proc/icon_has_state(icon, icon_state)
	ASSERT(icon)
	ASSERT(!isnull(icon_state)) // Empty string/text is resolved to `FALSE`, so should check for `null` explicitly

	var/list/cached_icon_states = get_cached_icon_states(icon)
	return !!cached_icon_states[icon_state]


/*
 * Checks if the `icon_state` is in one of the `icons`'s icon states
 *
 ** Returns: TRUE if icon state is present in any icon, FALSE otherwise.
 */
/repository/icon_states/proc/any_icon_has_state(list/icons, icon_state)
	ASSERT(!isnull(icon_state)) // Empty string/text is resolved to `FALSE`, so should check for `null` explicitly

	if(!length(icons))
		return FALSE

	for(var/icon in icons)
		if(icon_has_state(icon, icon_state))
			return TRUE

	return FALSE

/*
 * Private
 *
 * Tries to find cache of icon states in `icon`. If none found - new one is generated.
 *
 ** Returns: cached set of icon states for passed icon.
 */
/repository/icon_states/proc/get_cached_icon_states(icon)
	PRIVATE_PROC(TRUE)
	ASSERT(icon)

	var/list/cached_icon_states = icon_to_icon_states[icon]
	if(!cached_icon_states)
		cached_icon_states = generate_icon_states_cache(icon)

	return cached_icon_states

/*
 * Private
 *
 * Generates cache of icon states for passed icon path
 *
 ** Returns: cached set of icon states for passed icon path
 */
/repository/icon_states/proc/generate_icon_states_cache(icon)
	PRIVATE_PROC(TRUE)
	ASSERT(icon)

	var/list/cached_icon_states = list()
	for(var/icon_state in icon_states(icon))
		cached_icon_states[icon_state] = TRUE

	icon_to_icon_states[icon] = cached_icon_states

	return cached_icon_states
