/datum
	var/gc_destroyed //Time when this object was destroyed.
	var/is_processing = FALSE

	/// If this datum is pooled, the pool it belongs to.
	var/singleton/instance_pool/instance_pool

	/// If this datum is pooled, the last configurator applied (if any).
	var/singleton/instance_configurator/instance_configurator

	/**
	  * Components attached to this datum
	  *
	  * Lazy associated list in the structure of `type -> component/list of components`
	  */
	var/list/_datum_components
	/**
	  * Any datum registered to receive signals from this datum is in this list
	  *
	  * Lazy associated list in the structure of `signal -> registree/list of registrees`
	  */
	var/list/_listen_lookup
	/// Lazy associated list in the structure of `target -> list(signal -> proctype)` that are run when the datum receives that signal
	var/list/list/_signal_procs


// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy()
	SHOULD_CALL_PARENT(TRUE)
	SHOULD_NOT_SLEEP(TRUE)
	tag = null
	SSnano && SSnano.close_uis(src)
	if (extensions)
		for (var/expansion_key in extensions)
			var/list/extension = extensions[expansion_key]
			if (islist(extension))
				extension.Cut()
			else
				qdel(extension)
		extensions = null
	//BEGIN: ECS SHIT
	var/list/dc = _datum_components
	if(dc)
		for(var/component_key in dc)
			var/component_or_list = dc[component_key]
			if(islist(component_or_list))
				for(var/datum/component/component as anything in component_or_list)
					qdel(component, FALSE)
			else
				var/datum/component/C = component_or_list
				qdel(C, FALSE)
		dc.Cut()

	_clear_signal_refs()
	//END: ECS SHIT
	GLOB.destroyed_event && GLOB.destroyed_event.raise_event(src)
	cleanup_events(src)
	var/list/machines = global.state_machines["\ref[src]"]
	if (length(machines))
		for (var/base_type in machines)
			qdel(machines[base_type])
		global.state_machines -= "\ref[src]"
	if (instance_pool?.ReturnInstance(src))
		return QDEL_HINT_IWILLGC
	instance_configurator = null
	instance_pool = null
	weakref = null
	return QDEL_HINT_QUEUE

///Only override this if you know what you're doing. You do not know what you're doing
///This is a threat
/datum/proc/_clear_signal_refs()
	var/list/lookup = _listen_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/datum/component/comp as anything in comps)
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		_listen_lookup = lookup = null

	for(var/target in _signal_procs)
		UnregisterSignal(target, _signal_procs[target])


/datum/proc/Process()
	set waitfor = 0
	return PROCESS_KILL
