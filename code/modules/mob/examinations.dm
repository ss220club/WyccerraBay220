
/proc/examinate(mob/user, atom/A)
	if ((is_blind(user) || user.stat) && !isobserver(user))
		to_chat(user, chat_box_regular(SPAN_NOTICE("Something is there but you can't see it.")))
		return
	user.face_atom(A)
	if (user.simulated)
		if (A.loc != user || user.IsHolding(A))
			for (var/mob/M in viewers(4, user))
				if (M == user)
					continue
				if (M.client && M.client.get_preference_value(/datum/client_preference/examine_messages) == GLOB.PREF_SHOW)
					if (M.is_blind() || user.is_invisible_to(M))
						continue
					to_chat(M, SPAN_SUBTLE("<b>\The [user]</b> looks at \the [A]."))
	var/distance = INFINITY
	var/is_adjacent = FALSE
	if (isghost(user) || user.stat == DEAD)
		distance = 0
		is_adjacent = TRUE
	else
		var/turf/source_turf = get_turf(user)
		var/turf/target_turf = get_turf(A)
		if (source_turf && source_turf.z == target_turf?.z)
			distance = get_dist(source_turf, target_turf)
		is_adjacent = user.Adjacent(A)
	var/list/examine_info = A.examine(user, distance, is_adjacent)
	var/list/forensic_info = user.ForensicsExamination(A, distance, is_adjacent)
	examine_info += forensic_info
	if(length(examine_info))
		for(var/i in 1 to (length(examine_info) - 1))
			if(!examine_info[i])
				continue
			examine_info[i] += "\n"

	to_chat(user, chat_box_examine(examine_info.Join()))
	var/datum/codex_entry/entry = SScodex.get_codex_entry(A.get_codex_value())
	//This odd check v is done in case an item only has antag text but someone isn't an antag, in which case they shouldn't get the notice
	if(entry && (entry.lore_text || entry.mechanics_text || (entry.antag_text && player_is_antag(user.mind))) && user.can_use_codex())
		to_chat(user, chat_box_regular(SPAN_NOTICE("The codex has <b><a href='?src=\ref[SScodex];show_examined_info=\ref[A];show_to=\ref[user]'>relevant information</a></b> available.")))

/mob/proc/ForensicsExamination(atom/A, distance, is_adjacent)
	if(!(get_skill_value(SKILL_FORENSICS) >= SKILL_EXPERIENCED && distance <= (get_skill_value(SKILL_FORENSICS) - SKILL_TRAINED)))
		return
	. = list()
	var/clue = FALSE
	if(LAZYLEN(A.suit_fibers))
		. += SPAN_NOTICE("You notice some fibers embedded in [A].")
		clue = TRUE
	if(LAZYLEN(A.fingerprints))
		. += SPAN_NOTICE("You notice a partial print on [A].")
		clue = TRUE
	if(LAZYLEN(A.gunshot_residue))
		. += GunshotResidueExamination(A)
		clue = TRUE
	// Noticing wiped blood is a bit harder
	if((get_skill_value(SKILL_FORENSICS) >= SKILL_MASTER) && LAZYLEN(A.blood_DNA))
		. += SPAN_WARNING("You notice faint blood traces on [A].")
		clue = TRUE
	if(clue && has_client_color(/datum/client_color/noir))
		playsound_local(null, pick('sound/effects/clue1.ogg','sound/effects/clue2.ogg'), 60, is_global = TRUE)


/mob/proc/GunshotResidueExamination(atom/A)
	return SPAN_NOTICE("You notice a faint acrid smell coming from [A].")

/mob/living/GunshotResidueExamination(atom/A)
	if (isSynthetic())
		return SPAN_NOTICE("You notice faint black residue on [A].")
	else
		return SPAN_NOTICE("You notice a faint acrid smell coming from [A].")

/mob/living/silicon/GunshotResidueExamination(atom/A)
	return SPAN_NOTICE("You notice faint black residue on [A].")
